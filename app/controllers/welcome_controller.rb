class WelcomeController < ApplicationController
	require 'soundcloud'
	before_action :logged_in?, only: [:search, :index]

	@@genre = {}
	@@limit = {}
	@@duration = {}
	@@track_arr = {}
	@@names_arr = {}
	@@active_tracks = {}
	@@active_names = {}
	@@active_indices = {}
	@@saved_playlists = {}
	@@track_count = {}
	@@refresh_count = {}


	def splash
		@user = User.new
	end

	def start
		user = current_user
		@@active_tracks[user.id] = []
		@@active_names[user.id] = []
		@@limit[user.id] = 50
		@@active_indices[user.id] = []
		@@genre[user.id] = 'Please Pick A Valid Genre!'
		@@duration[user.id] = 45
		@@track_arr[user.id] = []
		@@names_arr[user.id] = []
		@@saved_playlists[user.id] = []
		@@track_count[user.id] = []
		@@refresh_count[user.id] = 1
		redirect_to '/home'
	end


	def index
		user = current_user
		p "limit: " + @@limit[user.id].to_s
		@tracks = @@active_tracks[user.id][0...@@limit[user.id]]
		@names = @@active_names[user.id][0...@@limit[user.id]]
		@indices = @@active_indices[user.id]
		@@track_count[user.id] = @tracks.length
		@duration = @@duration[user.id]
		@genre = @@genre[user.id]

		@playlist = Playlist.new

	end

	def get_songs
		user = current_user
		@@track_arr[user.id] = []
		@@names_arr[user.id] = []
		@@active_indices[user.id] = []
		@@refresh_count[user.id] = 1
		@@duration[user.id] = params[:minutes]
		@@limit[user.id] = params[:minutes].to_i / 4
		@@genre[user.id] = params[:genre]


		client = SoundCloud.new(client_id: ENV['API_KEY'])
		tracks = client.get('/tracks', :genres => @@genre[user.id], :limit => 50)
		puts tracks[1]
		tracks.each do |track|
			if track.streamable 
				url = track.uri.to_s + "/stream?client_id=#{ENV['API_KEY']}"	
				@@track_arr[user.id] << url
				@@names_arr[user.id] << track.title
			end
		end
		@@active_tracks[user.id] = @@track_arr[user.id].dup
		@@active_names[user.id] = @@names_arr[user.id].dup
		for i in 0..@@active_tracks[user.id].length
			@@active_indices[user.id] << i
		end
		redirect_to '/home'
	end

	def update
		user = current_user
		new_tracks = []
		new_names = []
		new_indices = []
		params.each do |key, val|
			if key == val
				new_tracks << @@track_arr[user.id][val.to_i]
				new_names << @@names_arr[user.id][val.to_i]
				new_indices << val.to_i
			end
		end
		p new_indices
		needed = @@track_count[user.id] - new_tracks.length
		for i in 0...needed
			new_tracks << @@track_arr[user.id][(@@track_count[user.id] * @@refresh_count[user.id]) + i]
			new_names << @@names_arr[user.id][(@@track_count[user.id] * @@refresh_count[user.id]) + i]
			new_indices << ((@@track_count[user.id] * @@refresh_count[user.id]) + i)
		end
		@@active_tracks[user.id] = new_tracks
		@@active_names[user.id] = new_names
		@@active_indices[user.id] = new_indices
		p @@active_indices[user.id]
		@@refresh_count[user.id] += 1
		redirect_to '/home'
	end

	def search
		user = current_user
      if params[:search]
        @playlists = @@saved_playlists[user.id] = Playlist.search(params[:search]).order("created_at DESC")
      else
        @playlists = @@saved_playlists[user.id] = Playlist.all.order('created_at DESC')
      end
   end

   def play
	   	user = current_user
	   	p params[:title]
	   	stored_lists = @@saved_playlists[user.id]
	   	retrieved_list = stored_lists.select { |playlist| playlist.title == params[:title]}
	   	@@active_tracks[user.id] = url_toArray(retrieved_list)
	   	@@active_names[user.id] = name_toArray(retrieved_list)
	   	redirect_to '/home'
   end



end





