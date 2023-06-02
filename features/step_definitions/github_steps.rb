Given("a file in Github located at {string}") do
  @this_will_pass = true
end

Given("a model backed by Github") do
  class ExampleModel < GitRecord::Remote
  end
end

Given("When I find")
