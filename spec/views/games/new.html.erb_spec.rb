require 'spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game,
      :user => nil,
      :score => 1,
      :length => 1
    ).as_new_record)
  end

  it "renders new game form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", games_path, "post" do
      assert_select "input#game_user[name=?]", "game[user]"
      assert_select "input#game_score[name=?]", "game[score]"
      assert_select "input#game_length[name=?]", "game[length]"
    end
  end
end
