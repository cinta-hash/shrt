json.extract! link, :id, :short_url, :long_url, :custom_url, :clicks, :created_at, :updated_at
json.url link_url(link, format: :json)
