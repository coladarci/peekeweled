class Game < ActiveRecord::Base
  belongs_to :user
  
  after_create :generate_cells
  
  private
    
    def generate_cells
      cells = []
      options = [:one, :two, :three, :four, :five, :six]
      64.times { |c| cells << options.sample }
      self.cells = cells.join(",")
    end
end
