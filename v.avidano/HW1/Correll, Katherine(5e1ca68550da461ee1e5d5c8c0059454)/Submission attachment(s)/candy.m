function [candyperkid, candywasted] = candy (numbercandy, numberkids)
candyperkid = floor(numbercandy./numberkids)
candywasted = mod(numbercandy,numberkids)
end