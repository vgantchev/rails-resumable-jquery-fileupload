class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :upload, :do_upload, :resume_upload, :update_status, :reset_upload]

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all.order(name: :asc)
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    # If upload is not commenced or finished, redirect to upload page
    return redirect_to upload_course_path(@course) if @course.status.in?(%w(new uploading))
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)
    @course.status = 'new'

    respond_to do |format|
      if @course.save
        format.html { redirect_to upload_course_path(@course), notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    @course.assign_attributes(status: 'new', upload: nil) if params[:delete_upload] == 'yes'

    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /courses/:id/upload
  def upload

  end

  # PATCH /courses/:id/upload.json
  def do_upload
    unpersisted_course = Course.new(upload_params)

    # If no file has been uploaded or the uploaded file has a different filename,
    # do a new upload from scratch
    if @course.upload_file_name != unpersisted_course.upload_file_name
      @course.assign_attributes(upload_params)
      @course.status = 'uploading'
      @course.save!
      render json: @course.to_jq_upload and return

    # If the already uploaded file has the same filename, try to resume
    else
      current_size = @course.upload_file_size
      content_range = request.headers['CONTENT-RANGE']
      begin_of_chunk = content_range[/\ (.*?)-/,1].to_i # "bytes 100-999999/1973660678" will return '100'

      # If the there is a mismatch between the size of the incomplete upload and the content-range in the
      # headers, then it's the wrong chunk! 
      # In this case, start the upload from scratch
      unless begin_of_chunk == current_size
        @course.update!(upload_params)
        render json: @course.to_jq_upload and return
      end
      
      # Add the following chunk to the incomplete upload
      File.open(@course.upload.path, "ab") { |f| f.write(upload_params[:upload].read) }

      # Update the upload_file_size attribute
      @course.upload_file_size = @course.upload_file_size.nil? ? unpersisted_course.upload_file_size : @course.upload_file_size + unpersisted_course.upload_file_size
      @course.save!

      render json: @course.to_jq_upload and return
    end
  end

  # GET /courses/:id/reset_upload
  def reset_upload
    # Allow users to delete uploads only if they are incomplete
    raise StandardError, "Action not allowed" unless @course.status == 'uploading'
    @course.update!(status: 'new', upload: nil)
    redirect_to @course, notice: "Upload reset successfully. You can now start over"
  end

  # GET /courses/:id/resume_upload.json
  def resume_upload
    render json: { file: { name: @course.upload.url(:default, timestamp: false), size: @course.upload_file_size } } and return
  end

  # PATCH /courses/:id/update_upload_status
  def update_status
    raise ArgumentError, "Wrong status provided " + params[:status] unless @course.status == 'uploading' && params[:status] == 'uploaded'
    @course.update!(status: params[:status])
    head :ok
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name)
  end

  def upload_params
    params.require(:course).permit(:upload)
  end
end
