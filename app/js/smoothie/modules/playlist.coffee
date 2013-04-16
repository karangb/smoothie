Smoothie.Modules.Playlist = ( () -> 

  # # Mockup data
  # mockup_tracks = [
  #     {
  #       id: '29462796',
  #       artwork: 'https://i4.sndcdn.com/artworks-000034170195-wb7buo-t500x500.jpg',
  #       title: 'Mammals - Move Slower Feat. Flash Forest (FREE D/L in description)',
  #       url: 'http://www.google.com',
  #       uploader_name: 'Flash Forest',
  #       uploader_url: 'http://www.google.com'
  #     },
  #     {
  #       id: '63392244',
  #       artwork: 'https://i4.sndcdn.com/artworks-000037931943-gkafnb-t500x500.jpg',
  #       title: 'Sir Sly - Gold',
  #       url: 'http://www.google.com',
  #       uploader_name: 'Sir Sly',
  #       uploader_url: 'http://www.google.com'
  #     },
  #     {
  #       id: '40289362',
  #       artwork: 'https://i1.sndcdn.com/artworks-000033642979-p06mxq-t500x500.jpg',
  #       title: 'The Temper Trap - Sweet Disposition (RAC Mix)',
  #       url: 'http://www.google.com',
  #       uploader_name: 'RAC',
  #       uploader_url: 'http://www.google.com'
  #     }
  # ]


  {

    # The current track index
    index: null

    # The fetched tracks array
    tracks: []

    # The current seed
    seed: null

    # The buffer after which tracks are fetched again
    buffer: 8

    init: (callback) ->
      @index = 0
      this.fetchTracks (tracks) =>
        Smoothie.Modules.Player.init(@getCurrentTrack().id)
        callback()

    # Change tracks
    next: () ->
      @index += 1
      Smoothie.Views.PlayerView.moveTracksForward()
      Smoothie.Modules.Player.fetchTrack(@getCurrentTrack().id)
      this.fetchTracks() if @index > (@tracks.length - 1 - @buffer)

    previous: () ->
      @index -= 1
      Smoothie.Views.PlayerView.moveTracksBackward()
      Smoothie.Modules.Player.fetchTrack(@getCurrentTrack().id)

    # Get tracks
    getPreviousTrack: () ->
      @tracks[@index - 1]

    getCurrentTrack: () ->
      @tracks[@index]

    getNextTrack: () ->
      @tracks[@index + 1]

    # Fetch tracks from api
    fetchTracks: (callback) ->
      return if @fetching == true
      @fetching = true

      url =  "/api/v1/tracks.json"
      url += "?id=2339203"
      url += "&seed=#{@seed}" if @seed
      url += "&offset=#{@tracks.length}"

      console.log "Fetching #{url}"
      $.getJSON url, (tracks) =>
        @seed = tracks.seed
        @tracks.push track for track in tracks.tracks
        @fetching = false

        callback(tracks)
  }
)()