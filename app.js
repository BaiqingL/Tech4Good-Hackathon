//react-native rukou,url

import BleManager from 'react-native-ble-manager';
const BleManagerModule = NativeModules.BleManager;
const bleManagerEmitter = new NativeEventEmitter(BleManagerModule);

BleManager.start({showAlert: false})
  .then( ()=>{
	   //检查蓝牙打开状态，初始化蓝牙后检查当前蓝牙有没有打开
       BleManager.checkState();
       console.log('Init the module success.');                
   }).catch(error=>{
       console.log('Init the module fail.');
   });

   //蓝牙状态改变监听
bleManagerEmitter.addListener('BleManagerDidUpdateState', (args) => {
	console.log('BleManagerDidUpdateStatea:', args);
	if(args.state == 'on' ){  //蓝牙已打开
		
	}
});

//扫描可用设备，5秒后结束 
BleManager.scan([], 5, true)
	.then(() => {
		console.log('Scan started');
	})
	.catch( (err)=>{
        console.log('Scan started fail');
    });
  
//停止扫描
BleManager.stopScan()
    .then(() => {
	    console.log('Scan stopped');
    })
    .catch( (err)=>{
		console.log('Scan stopped fail',err);
    });


//搜索到一个新设备监听
bleManagerEmitter.addListener('BleManagerDiscoverPeripheral', (data) => {
	console.log('BleManagerDiscoverPeripheral:', data);
	let id;  //蓝牙连接id
	let macAddress;  //蓝牙Mac地址            
	if(Platform.OS == 'android'){
	    macAddress = data.id;
	    id = macAddress;
	}else{  
	    //ios连接时不需要用到Mac地址，但跨平台识别是否是同一设备时需要Mac地址
        //如果广播携带有Mac地址，ios可通过广播0x18获取蓝牙Mac地址，
	    macAddress = getMacAddressFromIOS(data);
	    id = data.id;
    }            
});

//搜索结束监听
bleManagerEmitter.addListener('BleManagerStopScan', () => {
	 console.log('BleManagerStopScan:','Scanning is stopped');		
    //搜索结束后，获取搜索到的蓝牙设备列表，如监听了BleManagerDiscoverPeripheral,可省去这个步骤
    BleManager.getDiscoveredPeripherals([])
       .then((peripheralsArray) => {
           console.log('Discovered peripherals: ', peripheralsArray);
       });
});    


getMacAddressFromIOS(data){
	let macAddressInAdvertising = data.advertising.kCBAdvDataManufacturerMacAddress;
	//为undefined代表此蓝牙广播信息里不包括Mac地址
	if(!macAddressInAdvertising){  
        return;
    }
	macAddressInAdvertising = macAddressInAdvertising.replace("<","").replace(">","").replace(" ","");
	if(macAddressInAdvertising != undefined && macAddressInAdvertising != null && macAddressInAdvertising != '') {
	macAddressInAdvertising = swapEndianWithColon(macAddressInAdvertising);
    }
    return macAddressInAdvertising;
}

/**
* ios从广播中获取的mac地址进行大小端格式互换，并加上冒号:
* @param str         010000CAEA80
* @returns string    80:EA:CA:00:00:01
*/
swapEndianWithColon(str){
	let format = '';
	let len = str.length;
	for(let j = 2; j <= len; j = j + 2){
		format += str.substring(len-j, len-(j-2));
		if(j != len) {
			format += ":";
		}
	}
    return format.toUpperCase();
}

//连接蓝牙
BleManager.connect(id)
   .then(() => {
	   console.log('Connected');
   })
   .catch((error) => {
	   console.log('Connected error:',error);
   });
   
//断开蓝牙连接
BleManager.disconnect(id)
    .then( () => {
	    console.log('Disconnected');
    })
    .catch( (error) => {
	    console.log('Disconnected error:',error);
    });

    //蓝牙设备已连接监听
bleManagerEmitter.addListener('BleManagerConnectPeripheral', (args) => {
	log('BleManagerConnectPeripheral:', args);
});
         
//蓝牙设备已断开连接监听
bleManagerEmitter.addListener('BleManagerDisconnectPeripheral', (args) => {
	console.log('BleManagerDisconnectPeripheral:', args);
});