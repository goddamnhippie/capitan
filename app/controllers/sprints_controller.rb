class SprintsController < ApplicationController
  before_action :require_admin
  before_action :set_sprint, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  def index
    @branches = Branch.all

    # Admin has to belong to a group;
    # otherwise the following statement won't works
    @group_id = current_user.group_id

    @sprints = Group.find(@group_id).sprints
  end

  def show
    @lessons = @sprint.lessons
  end

  def group_sprints
    @group = Group.find(params[:group_id])
    @sprints = @group.sprints
    respond_to :js
  end

  def new
    @sprint = Sprint.new
  end

  def edit
  end

  def create
    # An extra empty string is always passed as a part of
    # sprint_params[lesson_ids] because of the hidden checkbox field whose
    # value is "". For more, see  #http://apidock.com/rails/ActionView/Helpers/FormHelper/check_box#1001-Sending-array-parameters
    # However without the following line of code, it works.
    # sprint_params['lesson_ids'].delete('')

    @sprint = Sprint.new(sprint_params)

    respond_to do |format|
      if @sprint.save
        format.html { redirect_to @sprint, notice: 'Sprint was successfully created.' }
        format.json { render :show, status: :created, location: @sprint }
      else
        format.html { render :new }
        format.json { render json: @sprint.errors, status: :unprocessable_entity }
      end
    end
end

  def update
    respond_to do |format|
      if @sprint.update(sprint_params)
        format.html { redirect_to @sprint, notice: 'Sprint was successfully updated.' }
        format.json { render :show, status: :ok, location: @sprint }
      else
        format.html { render :edit }
        format.json { render json: @sprint.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sprint.destroy
    respond_to do |format|
      format.html { redirect_to sprints_url, notice: 'Sprint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sprint
      @sprint = Sprint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sprint_params
      params.require(:sprint).permit(:name, :description, :group_id, lesson_ids: [])
    end
end
