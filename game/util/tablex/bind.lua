return function(tbl, method_name)
   assertx.is_table(tbl)
   assertx.is_string(method_name)

   return function(...)
      return tbl[method_name](tbl, ...)
   end
end
