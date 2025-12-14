class FormsController < ApplicationController
  before_action :set_form, only: [ :show, :edit, :update, :destroy ]

  def index
    @forms = Form.includes(:fields, :responses).all
  end

  def show
  end

  def new
    @form = Form.new
  end

  def create
    @form = Form.new(form_params)
    process_field_options(@form)

    if @form.save
      redirect_to @form, notice: "Form was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    assign_form_attributes(@form, form_params)
    process_field_options(@form)

    if @form.save
      redirect_to @form, notice: "Form was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @form.destroy
    redirect_to forms_url, notice: "Form was successfully destroyed."
  end

  private

  def set_form
    @form = Form.find(params[:id])
  end

  def form_params
    params.require(:form).permit(
      :title,
      fields_attributes: [ :id, :field_type, :label, :position, :options, :_destroy ]
    )
  end

  def assign_form_attributes(form, attributes)
    form.assign_attributes(attributes)
  end

  def process_field_options(form)
    form.fields.each do |field|
      next if field.field_type != "select" || field.options.blank?

      if field.options.is_a?(String)
        # Parse options: each line should be "label|value" or just "label" (value=label)
        field.options = field.options.split("\n").map(&:strip).reject(&:blank?).map do |line|
          parts = line.split("|").map(&:strip)
          if parts.size == 2
            { label: parts[0], value: parts[1] }
          else
            { label: line, value: nil }
          end
        end
      end
    end
  end
end
