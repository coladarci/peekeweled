class Game < ActiveRecord::Base
  belongs_to :user
  
  after_create :generate_cells
  
  private
    
    def generate_cells
      cells = []
      options = [:one, :two, :three, :four, :five, :six]
      64.times { |c| cells << options.sample }
      self.cells = cells.join(",")
      
      self.score = 0
      
      self.save
      
      #I want to generate all the cells up front so I can see how two people play the exact same game
      #think head to head play could be kinda cool.
      #cells = []
      #400.times { |c| cells << options.sample }
      #self.allCells = cells.join(',')
          
    end
end
