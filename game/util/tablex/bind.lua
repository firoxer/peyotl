return function(tbl, method_name)
   return function(...)
      return tbl[method_name](tbl, ...)
   end
end
