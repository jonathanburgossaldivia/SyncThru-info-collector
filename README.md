# SyncThru-info-collector
Samsung multifunctional toner information collector with SyncThru embedded web server, tested with embedded web servers of Samsung M5360RX, M5370LX and K7600LX MFPs

![Image description](https://github.com/jonathanburgossaldivia/SyncThru-info-collector/blob/master/Konsole.png)

## General information

Tested only on macOS Catalina, it should work on Linux.

### Prerequisites

Required gems:

```
nokogiri, net-ping
```

### Installing

If you are using macOS, the way to install the gems one by one is like this:

```
sudo gem install nokogiri
```

### How to use

Open Terminal app or other console app and execute:

```
ruby SyncThru_info_collector.rb mfps_list.txt
```

By default the program searches for all the multifunctional ones in the list, but you can limit by adding the remaining number of toner, 
In this example we see how to search for multifunctionals with remaining toner equal to or less than 50%:

```
ruby SyncThru_info_collector.rb mfps_list.txt 50
```


## Built With

* ruby 2.6.3p62 (2019-04-16 revision 67580) [universal.x86_64-darwin19]

## Authors

* **Jonathan Burgos Saldivia** - *on Github* - [jonathanburgossaldivia](https://github.com/jonathanburgossaldivia)

## License

This project is licensed under the Eclipse Public License 2.0 - see the [LICENSE.md](LICENSE.md) file for details
