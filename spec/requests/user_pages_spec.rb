require 'spec_helper'


describe "UserPages" do

  subject { page }

  describe "signup page" do
  	before { visit  signup_path }

  	it { should have_content('Sign up') }
  	it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
  end

  describe "signup" do

  	before { visit signup_path }
  	
  	let(:submit) { "Create my account" }

  	describe "with invalid information" do
  		it "should not create a user" do
  			expect { click_button submit }.not_to change(User, :count)
  		end 

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end

        # Exercise 7.6.2 - Error testing. Just to be sure. 
        # If you're looking a this and you know of a more efficient way to 
        # perform these tests, feel free to shoot me an email at 
        # ryan.darge@gmail.com - Thanks!
        #
      describe "with entry validation responses" do
        before do
          fill_in "Name",     with: "Ryan Darge"
          fill_in "Email",    with: "my.email@mail.com"
          fill_in "Password",   with: "foobar"
          fill_in "Confirmation", with: "foobar"
        end

        
        describe "name too long" do
          before do
            fill_in "Name",   with: "a" * 51
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Name is too long') } 
        end

        describe "name empty" do
          before do
            fill_in "Name",     with: ""
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Name can\'t be blank') } 
        end

        describe "email empty" do
          before do
            fill_in "Email",    with: ""
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Email can\'t be blank') } 
        end

        describe "email invalid" do
          before do
            fill_in "Email",    with: "my!email@mail..com"
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Email is invalid') } 
        end

        describe "password blank" do
          before do
            fill_in "Password",   with: ""
            fill_in "Confirmation", with: ""
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Password can\'t be blank') } 
        end

        describe "password too short" do
          before do
            fill_in "Password",   with: "foo"
            fill_in "Confirmation", with: "foo"
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Password is too short') } 
        end

        describe "password doesn't match" do
          before do
            fill_in "Password",   with: "foobar"
            fill_in "Confirmation", with: "barfoo"
            click_button submit
          end

          it { should have_title('Sign up') } 
          it { should have_error_message('error') } 
          it { should have_error_reason('Password confirmation doesn\'t match Password')}
        end
      end
  	end

  	describe "with valid information" do
  		before do
  			 valid_signup_fill
  		end

  		it "should create a a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

      describe "after saving the user" do
        before {click_button submit }
        let(:user) { User.find_by(email: 'example.email@mail.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }
      end
  	end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_error_message('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",               with: new_name
        fill_in "Email",              with: new_email
        fill_in "Password",           with: user.password
        fill_in "Confirm Password",   with: user.password
        click_button "Save changes" 
      end

      it { should have_title(new_name)     }
      it { should have_success_message('') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end
