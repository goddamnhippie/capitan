# == Schema Information
#
# Table name: pages
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  unit_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  page_type              :string(255)
#  sequence               :integer
#  instructions           :text(65535)
#  html                   :text(65535)
#  initial_state          :text(65535)
#  solution               :text(65535)
#  success_message        :string(255)
#  videotip               :string(255)
#  points                 :integer
#  question_points        :integer
#  selfLearning           :boolean          default(FALSE)
#  load_from_previous     :boolean
#  auto_corrector         :boolean          default(FALSE)
#  grade                  :integer          default(0)
#  slide_url              :string(255)
#  document_file_name     :string(255)
#  document_content_type  :string(255)
#  document_file_size     :integer
#  document_updated_at    :datetime
#  excercise_instructions :text(65535)
#

class Page < ActiveRecord::Base
  
  belongs_to :unit
  has_and_belongs_to_many :videos
  has_many :answers, :dependent => :destroy
  has_many :users, through: :answers
  has_many :question_groups, :dependent => :destroy
  has_many :questions, through: :question_groups
  
  accepts_nested_attributes_for :question_groups, 
                                 reject_if: proc { |attributes| attributes['sequence'].blank? }, 
                                 allow_destroy: true
  
  accepts_nested_attributes_for :answers
  
  has_attached_file :document
  validates_attachment :document, content_type: { content_type: ["application/zip","application/x-zip","application/x-zip-compressed"] }
  before_post_process :skip_for_zip

  def skip_for_zip
     ! %w(application/zip application/x-zip).include?(document_content_type)
  end  
  
  scope :editor_pages, -> { where(page_type: 'editor') }
  scope :question_pages, -> { where(page_type: 'questions') }
  
  def self.get_editor_pages_for_course(course_id)
    Page.editor_pages.includes(unit: :course).where(courses: {id: course_id})
  end
  
  def self.get_question_pages_for_course(course_id)
    Page.question_pages.includes(unit: :course).where(courses: {id: course_id})
  end


  def getCurrentQuestionGroupId(current_user)
    if (self.answers.where(:user_id => current_user.id).first.result == nil)
      return self.question_groups.first.id
    else
      answer_result = self.answers.where(:user_id => current_user.id).first.result
      s_result = answer_result.split(";")
      return s_result[0]
    end
  end
  
  def getCurrentSequence(current_user)
    return self.question_groups.find(self.getCurrentQuestionGroupId(current_user)).sequence if self.getCurrentQuestionGroupId(current_user) != "MAX"
  end
  
end
