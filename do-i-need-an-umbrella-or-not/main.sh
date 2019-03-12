source "./config"

city=$(curl -L ifconfig.co/city | sed 's/ /%20/g')
country=$(curl -L ifconfig.co/country-iso)
precip=$(curl -s "https://api.weatherbit.io/v2.0/current?city=${city}&country=${country}&key=d2cf09a6d3864dd0bf0a3c97dede2d37" | grep -E -o '.precip.{0,100}' | cut -d, -f 1 | cut -d: -f2)

if [[ $precip < 0.5 ]]; then
 echo "you need an umbrella today!"
else
 echo "leave that brolly at home!"
fi


