{
  inputs,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "bitbloxhub" true)
  ];
}
