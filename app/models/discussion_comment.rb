require 'zip'
class DiscussionComment < ActiveRecord::Base
  include FileHelper

  belongs_to :task_comment
  validates :task_comment, presence: true

  def status
    return "not started" if not started and not completed
    return "opened" if started and not completed
    return "complete"
  end

  def attachment_path(_count)
    FileHelper.comment_prompt_path(self.task_comment, ".wav", _count)
  end

  def reply_attachment_path
    FileHelper.comment_reply_prompt_path(self.task_comment, self.id, ".wav")
  end

  def startDiscussion()
    self.time_started = DateTime.now
    self.save!
  end

  def finishDiscussion()
    self.time_completed = DateTime.now
    self.save!
  end

  def dueDate
    created_at + 10.days
  end

  def started
    not time_started.nil?
  end

  def completed
    not time_completed.nil?
  end

  def get_prompt_files
    i_path = FileHelper.student_work_dir(:discussion, self.task_comment.task, false)
    i_path = i_path + self.task_comment.id.to_s

    files = Array.new

    i = 0
    flag = true
    while flag
      temp_path = "#{i_path}_#{i}.wav"
      
      if not File.exists? temp_path
        flag = false
        break
      end

      files.push temp_path
      i = i + 1
    end

    zip_file_path = FileHelper.zip_file_path_for_discussion_prompts(self.task_comment.task)

    zip_file = Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      files.each_with_index do |in_file, index|
        zip.add "#{index}.wav", "#{in_file}"
      end
    end

    return zip_file, zip_file_path

  end

  def add_prompt(file_upload, _count)
    temp = Tempfile.new(['discussion_comment', '.wav'])
    return false unless process_audio(file_upload.tempfile.path, temp.path)
    save
    logger.info("Saving audio prompt to #{attachment_path(_count)}")
    FileUtils.mv temp.path, attachment_path(_count)
  end

  def add_reply(current_user, reply_attachment)
    temp = Tempfile.new(['discussion_comment_reply', '.wav'])
    return false unless process_audio(file_upload.tempfile.path, temp.path)
    save
    logger.info("Saving discussion comment reply to #{reply_attachment_path()}")
    FileUtils.mv temp.path, reply_attachment_path()
  end
end