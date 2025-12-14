class ResponsesController < ApplicationController
  before_action :set_form

  def index
    @responses = @form.responses.order(created_at: :desc)
  end

  def show
    @response = @form.responses.includes(answers: :field).find(params[:id])
  end

  def new
    @response = @form.responses.build
    @form.fields.each do |field|
      @response.answers.build(field: field)
    end
  end

  def create
    @response = @form.responses.build(response_params)

    if @response.save
      redirect_to form_responses_path(@form), notice: "Response submitted successfully!"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_form
    @form = Form.find(params[:form_id])
  end

  def response_params
    params.require(:response).permit(
      answers_attributes: [ :field_id, :value ]
    )
  end
end
