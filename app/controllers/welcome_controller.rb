class WelcomeController < ApplicationController
	require 'SoundCloud'

	@@genre = 'Your Genre of Choice'
	@@limit = 50
	@@duration = 45
	@@track_arr = []
	@@names_arr = []
	@@active_tracks = []
	@@active_names = []
	@@active_indices = []
	@@saved_playlists = []
	@@track_count = 0
	@@refresh_count = 1


	def splash
	end

	def index
		@tracks = @@active_tracks[0...@@limit]
		@names = @@active_names[0...@@limit]
		@indices = @@active_indices
		@@track_count = @tracks.length
		@duration = @@duration
		@genre = @@genre

		@playlist = Playlist.new
	end

	def get_songs
		@@track_arr = []
		@@names_arr = []
		@@active_indices = []
		@@refresh_count = 1
		@@duration = params[:minutes]
		@@limit = params[:minutes].to_i / 4
		@@genre = params[:genre]


		client = SoundCloud.new(client_id: 'b61acae9ab94159d1de902fdee787599')
		tracks = client.get('/tracks', :genres => @@genre, :limit => 50)
		puts tracks[1]
		tracks.each do |track|
			if track.streamable 
				url = track.uri.to_s + "/stream?client_id=b61acae9ab94159d1de902fdee787599"	
				@@track_arr << url
				@@names_arr << track.title
			end
		end
		@@active_tracks = @@track_arr.dup
		@@active_names = @@names_arr.dup
		for i in 0..@@active_tracks.length
			@@active_indices << i
		end
		redirect_to '/home'
	end

	def update
		new_tracks = []
		new_names = []
		new_indices = []
		params.each do |key, val|
			if key == val
				new_tracks << @@track_arr[val.to_i]
				new_names << @@names_arr[val.to_i]
				new_indices << val.to_i
			end
		end
		p new_indices
		needed = @@track_count - new_tracks.length
		for i in 0...needed
			new_tracks << @@track_arr[(@@track_count * @@refresh_count) + i]
			new_names << @@names_arr[(@@track_count * @@refresh_count) + i]
			new_indices << ((@@track_count * @@refresh_count) + i)
		end
		@@active_tracks = new_tracks
		@@active_names = new_names
		@@active_indices = new_indices
		p @@active_indices
		@@refresh_count += 1
		redirect_to '/home'
	end


	def search

      if params[:search]
        @playlists = @@saved_playlists = Playlist.search(params[:search]).order("created_at DESC")
      else
        @playlists = @@saved_playlists = Playlist.all.order('created_at DESC')
      end
   end

   def play
   	p params[:title]
   	retrieved_list = @@saved_playlists.select { |playlist| playlist.title == params[:title]}
   	@@active_tracks = url_toArray(retrieved_list)
   	@@active_names = name_toArray(retrieved_list)
   	redirect_to '/home'
   end


end


