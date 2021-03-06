require 'rails_helper'

RSpec.describe 'merchant order show page' do
  describe 'As a merchant employee when I visit my merchant order show page (such as "/merchant/orders/15")' do
    before :each do
      @dog_shop = Merchant.create!(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
      @bike_shop = Merchant.create!(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @pull_toy = @dog_shop.items.create!(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @dog_bone = @dog_shop.items.create!(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21)
      @tire = @bike_shop.items.create!(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      @kiera = User.create!(name: 'Kiera Allen', address: '124 Main St.', city: 'Denver', state: 'CO', zip: 80205, email: 'bobmarley.com', password: 'password')

      @order_1 = @kiera.orders.create!(name: 'Kiera Allen', address: '124 Main St.', city: 'Denver', state: 'CO', zip: 80205, user_id: @kiera.id)
      @order_2 = @kiera.orders.create!(name: 'Kiera Allen', address: '124 Main St.', city: 'Denver', state: 'CO', zip: 80205, user_id: @kiera.id)

      @item_order_1 = @order_1.item_orders.create!(item_id: @pull_toy.id, price: 4.50, quantity: 2)
      @item_order_2 = @order_1.item_orders.create!(item_id: @dog_bone.id, price: 7.00, quantity: 1)
      @item_order_3 = @order_2.item_orders.create!(item_id: @dog_bone.id, price: 7.00, quantity: 500)
      @item_order_4 = @order_1.item_orders.create!(item_id: @tire.id, price: 8.00, quantity: 4)

      @sally = User.create!(name: 'Sally Peach', address: '432 Grove St.', city: 'Denver', state: 'CO', zip: 80205, email: 'sallypeach.com', password: 'password', role: 1, merchant_id: @dog_shop.id)

      visit '/login'

      fill_in :email, with: @sally.email
      fill_in :password, with: @sally.password

      click_button 'Login'
    end

    it "shows all items in that order from the merchant if they are not fulfilled" do

      visit "/merchant/orders/#{@order_1.id}"

      click_on(id: "item_order-#{@item_order_1.id}")

      visit "/merchant/orders/#{@order_1.id}"

      expect(page).to have_content(@order_1.id)
      expect(page).to have_content(@dog_bone.name)
    end

    it "shows the recipient's name and address used to create order" do

      visit "/merchant/orders/#{@order_1.id}"

      expect(page).to have_content(@kiera.name)
      expect(page).to have_content(@kiera.address)
      expect(page).to have_content(@kiera.city)
      expect(page).to have_content(@kiera.state)
      expect(page).to have_content(@kiera.zip)
    end

    it "only shows the items in the order purchased from my merchant" do

      visit "/merchant/orders/#{@order_1.id}"

      expect(page).to_not have_content(@tire.name)
    end

    it "shows each item's name (which is a link to that item's show page), image, price, and quantity user wants to purchase" do

      visit "/merchant/orders/#{@order_1.id}"

      click_link "#{@pull_toy.name}"
      expect(current_path).to eq("/items/#{@pull_toy.id}")

      visit "/merchant/orders/#{@order_1.id}"

      expect(page).to have_link(@pull_toy.name)
      expect(page).to have_css("img[src*='#{@pull_toy.image}']")
      expect(page).to have_content(@item_order_1.price)
      expect(page).to have_content(@item_order_1.quantity)

      expect(page).to have_link(@dog_bone.name)
      expect(page).to have_css("img[src*='#{@dog_bone.image}']")
      expect(page).to have_content(@item_order_2.price)
      expect(page).to have_content(@item_order_2.quantity)
    end

    it "should see an indicator that the item has been fulfilled, a flash message appears telling them its updated and inventory quantity is permeninatly reduced by user quantity" do
      visit "/merchant/orders/#{@order_1.id}"

      click_on(id: "item_order-#{@item_order_1.id}")

      expect(current_path).to eq("/merchant/orders/#{@order_1.id}")
      @item_order_1.reload
      expect(@item_order_1.item.inventory).to eq(30)
      expect(page).to have_content("fulfilled")
      expect(page).to have_content("Item has been fulfilled")
    end

    it "should not be able to fulfill an item in inventory is less than quantity" do
      visit "/merchant/orders/#{@order_2.id}"

      expect(page).to have_content("Cannot fulfill this item")
    end
  end
end
