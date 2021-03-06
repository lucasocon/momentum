require 'date'

class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:show, :edit, :update, :destroy]


  # Given recommendations filtered by user and neighborhood
  # return the status (:novice, :regular, :local)
  def retrieve_status(recommendations)
    score = 0
    recommendations.each do |recommendation|
      # score += recommendation.by_role * (1 / days_since(recommendation.created_at))
      score += 1 * (1 / days_since(recommendation.created_at))
    end

    case score
    when 0..10 then
      'novice'
    when 11..50 then
      'regular'
    else
      'local'
    end
  end

  def days_since(date)
    days = (date.to_date - Date.today.to_date).to_i
    if days == 0
      days = 1
    end
    days
  end

  # GET /recommendations
  # GET /recommendations.json
  def index
    if params[:day] && params[:time] && params[:neighborhood] && params[:intention]
      @recommendations = Recommendation.joins(:place).where(day: params[:day], time: params[:time], intention: params[:intention], 'places.neighborhood' => params[:neighborhood] )
    else
      @recommendations = Recommendation.all
    end
  end

  # GET /recommendations/1
  # GET /recommendations/1.json
  def show
  end

  # GET /recommendations/new
  def new
    @recommendation = Recommendation.new
  end

  # GET /recommendations/1/edit
  def edit
  end

  # POST /recommendations
  # POST /recommendations.json
  def create
    @recommendation = Recommendation.new(recommendation_params.slice(:intention, :time, :day))

    # only in the neighborhood
    @recommendation.by_role = retrieve_status(current_user.recommendations)

    # check if we have the Place
    if recommendation_params[:place_id]
      place = Place.find(recommendation_params[:place_id])
    else
      place = Place.find_or_create_by({name: recommendation_params[:name], google_place_id: recommendation_params[:google_place_id], neighborhood: recommendation_params[:neighborhood]})
    end
    @recommendation.place = place

    if recommendation_params[:user_id].present?
      @recommendation.user_id = recommendation_params[:user_id]
    else
      @recommendation.user = current_user
    end

    respond_to do |format|
      if @recommendation.save
        format.html { redirect_to @recommendation, notice: 'Recommendation was successfully created.' }
        format.json { render :show, status: :created, location: @recommendation }
      else
        format.html { render :new }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recommendations/1
  # PATCH/PUT /recommendations/1.json
  def update
    respond_to do |format|
      if @recommendation.update(recommendation_params)
        format.html { redirect_to @recommendation, notice: 'Recommendation was successfully updated.' }
        format.json { render :show, status: :ok, location: @recommendation }
      else
        format.html { render :edit }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recommendations/1
  # DELETE /recommendations/1.json
  def destroy
    @recommendation.destroy
    respond_to do |format|
      format.html { redirect_to recommendations_url, notice: 'Recommendation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recommendation
      @recommendation = Recommendation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recommendation_params
      params.require(:recommendation).permit(:by_role, :user_id, :place_id, :google_place_id, :name, :intention, :neighborhood, :time, :day)
    end
end
