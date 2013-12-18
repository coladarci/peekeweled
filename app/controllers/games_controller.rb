class GamesController < ApplicationController
  
  before_action :signed_in_user
  
  before_action :set_game, only: [:show, :edit, :update, :destroy, :end]
  
  before_action :owner, only: [:update]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = current_user.games.create()
    redirect_to game_path(@game)
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render action: 'show', status: :created, location: @game }
      else
        format.html { render action: 'new' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    puts "DID I GET HERE?"
    if params[:commit] == 'End Game'
      @game.ended_at = Time.current()
    end
    
    respond_to do |format|
      if @game.update(game_params)
        format.js
        format.html { redirect_to user_path }
      else
        format.json { render json: @game.errors, status: :unprocessable_entity }
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to user_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:user_id, :score, :length, :cells)
    end
    
    def owner
      redict_to root_path unless @game.user == current_user
    end
end
