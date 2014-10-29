every 1.hour do
  runner "::Jobs::GenerateDist.perform_async"
end
