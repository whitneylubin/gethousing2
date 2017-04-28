FileUploadService = ($http, $q, Upload, uuid) ->
  Service = {}
  # these are to be overridden
  Service.preferences = {}
  Service.session_uid = -> null

  Service.hasPreferenceFile = (fileType) ->
    Service.preferences[fileType] && !Service.preferenceFileIsLoading(fileType)

  Service.deletePreferenceFile = (prefType, listing_id, opts = {}) ->
    params =
      uploaded_file:
        session_uid: Service.session_uid()
        listing_id: listing_id
        preference: prefType

    if opts.rentBurdenType
      params.uploaded_file.rent_burden_type = opts.rentBurdenType
      params.uploaded_file.address = opts.address
      params.uploaded_file.rent_burden_index = opts.index
      proofDocument = Service.rentBurdenFile(opts)
    else
      proofDocument = Service.preferences.documents[prefType]
    if _.isEmpty(proofDocument) || _.isEmpty(proofDocument.file)
      return $q.reject()

    $http.delete('/api/v1/short-form/proof', {
      data: params,
      headers: {
        'Content-Type': 'application/json'
      },
    }).success((data, status, headers, config) ->
      # clear out fileObj
      if opts.rentBurdenType
        Service.clearRentBurdenFile(opts)
      else
        proofDocument.file = null
        proofDocument.proofOption = null
    ).error( (data, status, headers, config) ->
      return
    )

  Service.uploadProof = (file, prefType, listing_id, opts = {}) ->
    uploadedFileParams =
      file: file
      session_uid: Service.session_uid()
      listing_id: listing_id
      preference: prefType

    if prefType == 'rentBurden'
      proofDocument = Service.rentBurdenFile(opts)
      uploadedFileParams.address = opts.address
      uploadedFileParams.rent_burden_type = opts.rentBurdenType
      uploadedFileParams.rent_burden_index = opts.index
    else
      Service.preferences.documents[prefType] ?= {}
      proofDocument = Service.preferences.documents[prefType]

    uploadedFileParams.document_type = proofDocument.proofOption

    if (!file)
      proofDocument.error = true
      return $q.reject()

    proofDocument.loading = true

    Upload.upload(
      url: '/api/v1/short-form/proof'
      method: 'POST'
      data:
        uploaded_file: uploadedFileParams
    ).then( ((resp) ->
      proofDocument.loading = false
      proofDocument.error = false
      proofDocument.file = resp.data
    ), ((resp) ->
      # error handler
      proofDocument.loading = false
      proofDocument.error = true
    ))

  # Rent Burden specific functions
  Service.uploadedRentBurdenRentFiles = (address) ->
    files = Service.preferences.documents.rentBurden[address].rent
    _.filter(files, (file) -> !_.isEmpty(file.file))

  Service.rentBurdenFile = (opts) ->
    rentBurdenDocs = Service.preferences.documents.rentBurden[opts.address]
    return {} unless rentBurdenDocs
    if opts.rentBurdenType == 'lease'
      rentBurdenDocs.lease
    else
      rentBurdenDocs.rent[opts.index]

  Service.clearRentBurdenFile = (opts) ->
    rentBurdenDocs = Service.preferences.documents.rentBurden[opts.address]
    return unless rentBurdenDocs
    if opts.rentBurdenType == 'lease'
      angular.copy({}, rentBurdenDocs.lease)
    else
      # remove pref file at opts.index
      delete rentBurdenDocs.rent[opts.index]

  Service.clearRentBurdenFiles = (address = null) ->
    if address
      rentBurdenDocs = Service.preferences.documents.rentBurden[address]
      angular.copy({}, rentBurdenDocs.lease)
      angular.copy({}, rentBurdenDocs.rent)
    else
      _.each Service.preferences.documents.rentBurden, (doc, address) ->
        rentBurdenDocs = Service.preferences.documents.rentBurden[address]
        angular.copy({}, rentBurdenDocs.lease)
        angular.copy({}, rentBurdenDocs.rent)

  Service.deleteRentBurdenPreferenceFiles = (listing_id, address = null) ->
    params =
      uploaded_file:
        session_uid: Service.session_uid()
        listing_id: listing_id
    # if no address provided, we are deleting *all* rentBurdenFiles for this user/listing
    params.uploaded_file.address = address if address

    $http.delete('/api/v1/short-form/rent-burden-proof', {
      data: params,
      headers: {
        'Content-Type': 'application/json'
      },
    }).success((data, status, headers, config) ->
      # clear out fileObj
      Service.clearRentBurdenFiles(address)
    ).error( (data, status, headers, config) ->
      return
    )

  return Service

############################################################################################
######################################## CONFIG ############################################
############################################################################################

FileUploadService.$inject = [
  '$http', '$q', 'Upload', 'uuid'
]

angular
  .module('dahlia.services')
  .service('FileUploadService', FileUploadService)
