Rails.application.config.middleware.use OmniAuth::Builder do
  #I know this is bad - but for this demo, I'm not inclined to protect my keys w/ ENV vars :)
  provider :twitter, "2oiy64m06NiTIRlHFS4DQ", "5qzvu2tkCzkImYApx4guAbS59FYQlO7RyujBNju4",
    {
      :secure_image_url => 'true',
      :image_size => 'original',
      :authorize_params => {

      }
    }
end