class PagesController < ApplicationController
  
  before_action :set_course, except: [:saveAnswer,:saveQuestion]
  before_action :set_unit, except: [:saveAnswer,:saveQuestion]

  # GET /pages
  # GET /pages.json
  def index
    @pages = @unit.pages.all
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = @unit.pages.find(params[:id])
    @previous_page = @unit.pages.find_by_sequence(@page.sequence-1)
    @next_page = @unit.pages.find_by_sequence(@page.sequence+1)
    @page.answers.find_or_create_by(page_id: @page.id,user_id: current_user.id)
  end

  # GET /pages/new
  def new
    @page = @unit.pages.new
    @page.questions.build
  end

  # GET /pages/1/edit
  def edit
    @page = @unit.pages.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @unit.pages.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to course_unit_pages_path(@course,@unit), notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      @page = @unit.pages.find(params[:id])
      if @page.update(page_params)
        format.html { redirect_to course_unit_pages_path(@course,@unit), notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = @unit.pages.find(params[:id])
    @page.destroy
    respond_to do |format|
      format.html { redirect_to course_unit_pages_url(@course,@unit), notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def saveAnswer
    answer = Answer.find_by_page_id_and_user_id(params[:page_id],current_user.id)
    if answer != nil
      answer.result = params[:answer]
      answer.save
      render :json => { :status => :ok, :message => "success" }
    end
  end
  
  def saveQuestion
    answer = Answer.find_by_page_id_and_user_id(params[:page_id],current_user.id)
    if answer != nil
      
      questionGroup = QuestionGroup.find_by_sequence(params[:sequence].to_i+1)
      
      if answer.result == nil
        result = "#{questionGroup != nil ? questionGroup.id : "MAX"};#{params[:question_group_id]}|#{params[:option_id]}"
      else
        parts = answer.result.split(";")
        result = "#{questionGroup != nil ? questionGroup.id : "MAX"};#{parts[1,parts.length].join(";")};#{params[:question_group_id]}|#{params[:option_id]}"
      end
      answer.result = result
      answer.save
      render :json => { :status => :ok, :questionGroupId => questionGroup != nil ? questionGroup.id : nil, :sequence => questionGroup != nil ? params[:sequence].to_i+1 : "MAX" }
    end
  end

  private
    def set_course
      @course = Course.find(params[:course_id])
    end
    
    def set_unit
      @unit = @course.units.find(params[:unit_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:title, :page_type,:sequence, :unit_id, :html, :instructions,:video_ids => [],question_groups_attributes: [ :id,:sequence, :question_id, :_destroy])
    end
end
