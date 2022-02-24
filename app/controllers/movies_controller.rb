class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      session.clear unless request.url.include? "/movies"
      
      @all_ratings = Movie.uniq.pluck(:rating)

      # Update session selected ratings if the ratings query is updated.
      if params[:ratings] != nil && session[:ratings] != params[:ratings]
        session[:ratings] = params[:ratings] 
      end

      # Update session sort if the sort query is updated.
      if params[:sort_by] != nil && session[:sort_by] != params[:sort_by]
        session[:sort_by] = params[:sort_by]
      end

      # If anythings is missing from query params and is available in session, get it from session.
      if params[:ratings] == nil && params[:sort_by] == nil 
        if session[:ratings] != nil && session[:sort_by] != nil
          redirect_to movies_path(:sort_by => session[:sort_by], :ratings => session[:ratings])
        elsif session[:ratings] != nil
          redirect_to movies_path(:ratings => session[:ratings])
        elsif session[:sort_by] != nil
          redirect_to movies_path(:sort_by => session[:sort_by])
        end
      elsif params[:ratings] == nil && session[:ratings] != nil
        redirect_to movies_path(:sort_by => params[:sort_by], :ratings => session[:ratings])
      elsif params[:sort_by] == nil && session[:sort_by] != nil
        redirect_to movies_path(:sort_by => session[:sort_by], :ratings => params[:ratings])
      end

      @selected = params[:ratings] == nil ? @all_ratings : params[:ratings].keys
      # puts "params[:ratings]",params[:ratings]
      # puts "selected", @selected
      if params[:sort_by]
        @movies = Movie.where({rating: @selected}).order(params[:sort_by])
      else
        @movies = Movie.where({rating: @selected})
      end
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end