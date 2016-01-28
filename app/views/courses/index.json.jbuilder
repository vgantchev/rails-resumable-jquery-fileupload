json.array!(@courses) do |course|
  json.extract! course, :id
  json.url course_url(course, format: :json)
end
