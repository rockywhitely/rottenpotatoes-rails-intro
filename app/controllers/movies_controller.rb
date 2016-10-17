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
    @checked = params[:ratings]
    if @checked != nil
      @pick_rating = params[:ratings].keys.to_a
    else
      @pick_rating = @all_ratings
      @checked = {}
      @checked["no_rating"] = "no_rating"
    end
    puts @checked.inspect
    if params[:sort] == 'title'
      @title_header = 'hilite'
    elsif params[:sort] == 'release_date'
      @release_date_header ='hilite'
    end 
    @movies = Movie.where(rating: @pick_rating).order(params[:sort])
    #@all_ratings.each do |rating|
      #@checked[rating] = (@pick_rating.match(rating) || 0)
    #end
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