source "./config"

city=$(curl -L ifconfig.co/city | sed 's/ /%20/g')
country=$(curl -L ifconfig.co/country-iso)
precip=$(curl -s "https://api.weatherbit.io/v2.0/current?city=${city}&country=${country}&key=${ApiKey}" | grep -E -o '.precip.{0,100}' | cut -d, -f 1 | cut -d: -f2)

if [[ $precip < 0.5 ]]; then
 echo "you need an umbrella today!"
else
 echo "leave that brolly at home!"
fi


