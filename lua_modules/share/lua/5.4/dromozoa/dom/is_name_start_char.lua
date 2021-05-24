return function (c)
  c = c + 0
  if c < 131070 then
    if c < 894 then
      if c < 123 then
        if c < 91 then
          if c < 59 then
            return c >= 58
          else
            return c >= 65
          end
        else
          if c < 96 then
            return c >= 95
          else
            return c >= 97
          end
        end
      else
        if c < 247 then
          if c < 215 then
            return c >= 192
          else
            return c >= 216
          end
        else
          if c < 768 then
            return c >= 248
          else
            return c >= 880
          end
        end
      end
    else
      if c < 12272 then
        if c < 8206 then
          if c < 8192 then
            return c >= 895
          else
            return c >= 8204
          end
        else
          if c < 8592 then
            return c >= 8304
          else
            return c >= 11264
          end
        end
      else
        if c < 64976 then
          if c < 55296 then
            return c >= 12289
          else
            return c >= 63744
          end
        else
          if c < 65534 then
            return c >= 65008
          else
            return c >= 65536
          end
        end
      end
    end
  else
    if c < 655358 then
      if c < 393214 then
        if c < 262142 then
          if c < 196606 then
            return c >= 131072
          else
            return c >= 196608
          end
        else
          if c < 327678 then
            return c >= 262144
          else
            return c >= 327680
          end
        end
      else
        if c < 524286 then
          if c < 458750 then
            return c >= 393216
          else
            return c >= 458752
          end
        else
          if c < 589822 then
            return c >= 524288
          else
            return c >= 589824
          end
        end
      end
    else
      if c < 851968 then
        if c < 786430 then
          if c < 720894 then
            return c >= 655360
          else
            return c >= 720896
          end
        else
          if c < 851966 then
            return c >= 786432
          else
            return false
          end
        end
      else
        if c < 917504 then
          return c < 917502
        else
          return c < 983038
        end
      end
    end
  end
end
