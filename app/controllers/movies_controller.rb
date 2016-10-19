class MoviesController < ApplicationController
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    @all_ratings = Movie::RATINGS
    @pick_sort = nil
    @redirect = false
    
    if params[:ratings] == nil && params[:sort] == nil
      if session[:ratings] == nil 
        session[:ratings] = {"G"=>1, "PG"=>1, "PG-13"=>1, "R"=>1}
      end
      if session[:sort] == "release_date"
        @release_date_header = 'hilite'
        @pick_sort = "release_date"
      else
        @title_header = 'hilite'
        @pick_sort = "title"
      end

      @pick_rating = session[:ratings].keys.to_a 
      @checked = session[:ratings]
      @redirect = true
    end
    
    @checked = params[:ratings]
    if params[:ratings] != nil 
      session[:ratings] = params[:ratings]
      @pick_rating = params[:ratings].keys.to_a
    else
      if session[:ratings] != nil
        @pick_rating = session[:ratings].keys.to_a
        @checked = session[:ratings]
        @redirect = true
      else
        @pick_rating = @all_ratings
        @checked = Hash.new
        @all_ratings.each { |rating| @checked[rating] = 1 }
      end
    end

    if params[:sort] != nil
      session[:sort] = params[:sort]
      if params[:sort] == 'title'
        @title_header = 'hilite'
      elsif params[:sort] == 'release_date'
        @release_date_header ='hilite'
      end
      @pick_sort = params[:sort]
    else
      if session[:sort] == 'title'
        @title_header = 'hilite'
      elsif session[:sort] == 'release_date'
        @release_date_header ='hilite'
      end
      @pick_sort = session[:sort]
      @redirect = true
    end

    @pick_rating.each do |rating|
      @checked[rating] = 1
    end

    if @redirect
      flash.keep
      redirect_to movies_path :sort=>session[:sort], :ratings=>session[:ratings]
    end
    
    @movies = Movie.where(rating: @pick_rating).order(@pick_sort)

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
  
end