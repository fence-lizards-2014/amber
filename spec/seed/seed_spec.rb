require 'spec_helper'

describe Seed do
	describe "when seeding genres" do
		it "creates BeerGenre objects when passed a valid json formatted string" do
			genre_string = '[{"name": "Cream Ale","description": "So full of foo, this genre goes well with bar"}]'
			expect{Seed.genres(genre_string)}.to change{BeerGenre.count}.by(1)
		end
	end

	describe "when seeding flavors" do
		it "creates FoodFlavor objects when passed a valid json formatted string" do
			flavors = '[{"name": "salty"},{"name": "spicy"}]'
			expect{Seed.flavors(flavors)}.to change{FoodFlavor.count}.by(2)
		end
	end

	describe "when seeding beer objects" do
		let(:sample_api_response){File.read("#{Rails.root}/spec/dummy_api_resp.json")}
		let(:unverified_beer){JSON.parse(File.read("#{Rails.root}/spec/unverified_beer_sample.json"))}
		let(:verified_beer){JSON.parse(File.read("#{Rails.root}/spec/verified_beer_sample.json"))}

		context "when parsing beer data api response" do
			it "returns a collection of beer information when given a json format string" do
				expect(Seed.parse_beer_data(sample_api_response)).to be_instance_of(Array)
			end
		end

		context "when creating beer objects with parsed beer data" do
			it "only creates a beer if data has a status of 'verified'" do
				expect{Seed.create_beer_objects(unverified_beer)}.to_not change{Beer.count}
			end
			it "only creates a beer if data has a status of 'verified'" do
				expect{Seed.create_beer_objects(verified_beer)}.to change{Beer.count}.by(1)
			end
		end

		context "when changing a beer category" do
			it "sets the category of the beer to the style of the beer if it is not something we want to change" do
				beer = FactoryGirl.create(:beer, style: "Pond Water")
				expect(Seed.set_beer_category(beer, beer.style).category).to eq("Pond Water")
			end
			it "sets the beer category to 'Cream Ale / Blonde Ale' if it has the style 'American-Style Cream Ale or Lager'" do
				beer = FactoryGirl.create(:beer, style: "American-Style Cream Ale or Lager")
				expect(Seed.set_beer_category(beer, beer.style).category).to eq("Cream Ale / Blonde Ale")
			end
			it "sets the beer category to 'Old Ale / Strong Ale' if it has the style 'Strong Ale Belgian-Style Pale Strong Ale'" do
				beer = FactoryGirl.create(:beer, style: "Strong Ale Belgian-Style Pale Strong Ale")
				expect(Seed.set_beer_category(beer, beer.style).category).to eq("Old Ale / Strong Ale")
			end
		end
	end

	describe "when seeding matches" do
		before(:each) do
			Seed.flavors(File.read("#{Rails.root}/db/food_flavors.json"))
			Seed.genres(File.read("#{Rails.root}/db/beer_genres.json"))
		end

		it "creates four matches for the 'Bitter' beer genre category" do
			Seed.matches(File.read("#{Rails.root}/db/matches.json"))
			expect(BeerGenre.find_by_name("Bitter").matches.length).to eq(4)
		end
	end

end


  def self.matches(matches)
    all_matches = JSON.parse(matches)
    all_matches.each do |match|
      Match.create(beer_genre: BeerGenre.find_by_name(match["beer_genre"]),
                  food_flavor: FoodFlavor.find_by_name(match["food_flavor"]),
                  intensity: match["intensity"])
    end
  end

