angular.module('dahlia.components')
.component 'listingResultsToggler',
  templateUrl: 'listings/components/listing-results-toggler.html'
  bindings:
    listingResults: '<'
    sectionName: '@'
    icon: '@'
  controller: ['$translate', ($translate) ->
    ctrl = @
    @toggleStates = {}
    @text = {}

    this.$onInit = ->
      @setupText()

      @displayToggledSection = @toggleStates[@sectionName] ? false
      @togglerId = "#{@sectionName}-toggler"

      @hasListings = !!@listingResults.length

      @toggleListings = (e) ->
        # When you use keyboard nav to click on the button inside the header
        # for some reason it triggers both a MouseEvent and KeyboardEvent.
        # So, we ignore the KeyboardEvent.
        return if e.constructor.name == 'KeyboardEvent' and angular.element(e.target).hasClass('button')
        e.currentTarget.blur() if e
        @displayToggledSection = !@displayToggledSection
        @toggleStates[@sectionName] = @displayToggledSection

    @setupText = ->
      switch @sectionName
        when 'lotteryResults'
          @text = {
            title: $translate.instant('LISTINGS.LOTTERY_RESULTS.TITLE')
            subtitle: $translate.instant('LISTINGS.LOTTERY_RESULTS.SUBTITLE')
            showResults: $translate.instant('LISTINGS.LOTTERY_RESULTS.SHOW')
            hideResults: $translate.instant('LISTINGS.LOTTERY_RESULTS.HIDE')
            noResults: $translate.instant('LISTINGS.LOTTERY_RESULTS.NO_RESULTS')
          }
        when 'notMatched'
          @text = {
            title: $translate.instant('LISTINGS.ADDITIONAL_LISTINGS.TITLE')
            subtitle: $translate.instant('LISTINGS.ADDITIONAL_LISTINGS.SUBTITLE')
            showResults: $translate.instant('LISTINGS.ADDITIONAL_LISTINGS.SHOW')
            hideResults: $translate.instant('LISTINGS.ADDITIONAL_LISTINGS.HIDE')
          }
        when 'upcomingLotteries'
          @text = {
            title: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.TITLE')
            subtitle: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.SUBTITLE')
            showResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.SHOW')
            hideResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.HIDE')
            noResults: $translate.instant('LISTINGS.UPCOMING_LOTTERIES.NO_RESULTS')
          }

    return ctrl
  ]
