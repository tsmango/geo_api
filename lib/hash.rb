class Hash
  
  # Produces a query string from the key value pairs in this Hash.
  #   Note: This isn't my code and was written for merb.
  # 
  #   Reference for merb claim:
  #   http://stackoverflow.com/questions/798710/how-to-turn-a-ruby-hash-into-http-params
  # 
  # @return [String] a query string representation of this Hash.
  def to_params
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      else
        params << "#{k}=#{v}&"
      end
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{v}&"
        end
      end
    end

    params.chop!
    params
  end
end