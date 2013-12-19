class GamesController < ApplicationController
  
  before_action :signed_in_user
  
  before_action :set_game, only: [:show, :edit, :update, :destroy, :dual]
  
  before_action :owner, only: [:update]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
    unless @game.dual_id.nil?
      redirect_to game_dual_path(@game,Game.find(@game.dual_id))
    end
  end
  
  def dual
    @game2 = Game.find(params[:game_two_id])
  end

  # GET /games/new
  def new
    @game = current_user.games.create()
    redirect_to game_path(@game)
  end
  
  def new_dual
    @users = User.where('id != ?', current_user.id)  
  end
  def create_dual
    @game = current_user.games.create()
    @game2 = User.find(params[:partner_id]).games.create({dual_id: @game.id, cells: @game.cells, allCells: @game.allCells})
    @game.dual_id = @game2.id
    @game.save
    
    redirect_to game_dual_path(@game,@game2), notice: "Game Created! You should probably manually send your friend this link."   
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
      @game = Game.find(params[:game_id] ||= params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:user_id, :score, :length, :cells)
    end
    
    def owner
      redict_to root_path unless @game.user == current_user
    end
end
