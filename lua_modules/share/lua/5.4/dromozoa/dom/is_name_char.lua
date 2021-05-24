return function (c)
  c = c + 0
  if c < 64976 then
    if c < 247 then
      if c < 96 then
        if c < 59 then
          if c < 47 then
            return c >= 45
          else
            return c >= 48
          end
        else
          if c < 91 then
            return c >= 65
          else
            return c >= 95
          end
        end
      else
        if c < 184 then
          if c < 123 then
            return c >= 97
          else
            return c >= 183
          end
        else
          if c < 215 then
            return c >= 192
          else
            return c >= 216
          end
        end
      end
    else
      if c < 8257 then
        if c < 8192 then
          if c < 894 then
            return c >= 248
          else
            return c >= 895
          end
        else
          if c < 8206 then
            return c >= 8204
          else
            return c >= 8255
          end
        end
      else
        if c < 12272 then
          if c < 8592 then
            return c >= 8304
          else
            return c >= 11264
          end
        else
          if c < 55296 then
            return c >= 12289
          else
            return c >= 63744
          end
        end
      end
    end
  else
    if c < 524286 then
      if c < 262142 then
        if c < 131070 then
          if c < 65534 then
            return c >= 65008
          else
            return c >= 65536
          end
        else
          if c < 196606 then
            return c >= 131072
          else
            return c >= 196608
          end
        end
      else
        if c < 393214 then
          if c < 327678 then
            return c >= 262144
          else
            return c >= 327680
          end
        else
          if c < 458750 then
            return c >= 393216
          else
            return c >= 458752
          end
        end
      end
    else
      if c < 786430 then
        if c < 655358 then
          if c < 589822 then
            return c >= 524288
          else
            return c >= 589824
          end
        else
          if c < 720894 then
            return c >= 655360
          else
            return c >= 720896
          end
        end
      else
        if c < 917502 then
          if c < 851966 then
            return c >= 786432
          else
            return c >= 851968
          end
        else
          if c < 983038 then
            return c >= 917504
          else
            return false
          end
        end
      end
    end
  end
end
