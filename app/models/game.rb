class Game < ActiveRecord::Base
  belongs_to :user
  
  after_create :generate_cells
  
  private
    
    def generate_cells
      cells = []
      options = [:a, :b, :c, :d, :e, :f]
      
      #some logic to make sure that only boards that don't have a ton of connecting pieces
      lastRow = false
      
      64.times do |c| 
        
        begin
          sample = options.sample
        end while sample == lastRow
        
        lastRow = sample
        cells << sample
      end
      
      self.cells = cells.join(",")
      
      self.score = 0
      
      
      
      #I want to generate all the upcoming cells up front so that in dual mode they are fare games
      cells = []
      600.times { |c| cells << options.sample }
      self.allCells = cells.join(',')
      
      self.save
          
    end
end
