module Response
  EXCEPT_ATTRIBUTES = [:password, :password_digest]

  def json_response(object, status = :ok)
    render json: object, except: EXCEPT_ATTRIBUTES, status: status
  end
end
