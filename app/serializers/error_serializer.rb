class ErrorSerializer
  def initialize(errors, status: :unprocessable_entity)
    @errors = errors
    @status = status
  end

  def as_json
    {
      errors: format_errors,
      status: Rack::Utils.status_code(@status)
    }
  end

  private

  def format_errors
    case @errors
    when String
      [ { message: @errors } ]
    when Array
      @errors.map { |error| { message: error } }
    when Hash
      @errors.map do |field, messages|
        Array(messages).map do |message|
          { field: field, message: message }
        end
      end.flatten
    when ActiveModel::Errors
      @errors.map do |error|
        {
          field: error.attribute,
          message: error.full_message
        }
      end
    else
      [ { message: "An error occurred" } ]
    end
  end
end
