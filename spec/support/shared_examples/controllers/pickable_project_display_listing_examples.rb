# frozen_string_literal: true

RSpec.shared_examples_for "pickable project display listing" do |default|
  describe "display_mode" do
    it "assigns '#{default}' by default" do
      do_request
      expect(assigns(:display_mode).current).to eq default
    end

    it "assigns 'compact' for mobile device" do
      request.headers["User-Agent"] = "Android mobile"
      do_request
      expect(assigns(:display_mode).current).to eq "compact"
    end

    DisplayMode.new.available.each do |mode|
      it "assigns #{mode.inspect} when requested explicitly" do
        do_request display: mode
        expect(assigns(:display_mode).current).to eq mode
      end
    end
  end
end
