 passwall-smartdns分支编译 [xiaorouji](https://github.com/xiaorouji/openwrt-passwall/tree/luci-smartdns-dev)<br>
~~依赖同passwall~~ [xiaorouji/openwrt-passwall/releases](https://github.com/xiaorouji/openwrt-passwall/releases)<br>
xiaorouji大佬终于编译该版本，以后可能会发布正式版 [xiaorouji/openwrt-passwall/releases](https://github.com/xiaorouji/openwrt-passwall/releases)<br>该仓库已停止编译仅作教程<br>
需要安装[smartdns](https://github.com/pymumu/smartdns/releases)(~~compat版是为了向下兼容,23.05及以上安装后可能导致luci不显示smartdns服务~~)后才会有dns分流选项:<br>
![imag dns分流选项](/img/1.png)<br>
可直接绑定smartdns到53端口。<br><br>
# 个人使用的配置
## smartdns部分 ver: 1.2024.02.08-0828
### 高级设置
![imag dns配置1](/img/7.png)<br>
![imag dns配置2](/img/8.png)<br>
![imag dns配置3](/img/9.png)<br>
### 常规设置
![imag dns配置4](/img/5.png)<br>
服务器名称可以自己改<br>
isp和isp2的服务器ip根据运营商和地区填写<br>
以下是常用[dns服务器列表](https://dns.iui.im/#telecom)<br>
### 上游服务器设置
![imag dns配置5](/img/6.png)<br>
服务器组必须与passwall中国内分组名一致，我这里填的cn<br>
从[默认服务器组排除](#从默认服务器组排除)选项后面有介绍
## passwall部分 ver: 4.77-5-smartdns-dev
### dns设置
![imag dns1](/img/2.png)<br>
过滤代理域名 IPv6勾选后将会过滤掉国外dns返回的IPv6解析结果，相当于只用IPv4代理。<br>
勾选前:![imag cmd1](/img/11.png)<br>
勾选后:![imag cmd2](/img/12.png)<br>
### 从默认服务器组排除
passwall中如果没有勾选，smartdns的上游服务器配置中都勾选了，就相当于默认dns为远程![imag dns1](/img/4.png)<br>
相反如果passwall中勾选，smartdns的上游服务器配置中没有勾选，就相当于默认dns为直连![imag dns1](/img/3.png)<br>
注意：默认dns为远程时，停止passwall后会导致dns不解析(因为smartdns没有规则时默认走default服务器组，passwall停止运行后，上游服务器只设置了cn，导致dns不解析。使用直连dns就不会存在这个问题)，使用时确保两者同时运行。<br>
<br>
<br>
# END:<br>
由于smartdns无法做到dns精准分流，dns由默认节点解析返回，实际访问时会使用自己设置的节点，导致dns解析和访问网站时不是同一节点。<br>
对于单个节点用户，多节点都在同一地区，多节点不同地区但不需要分流的的用户影响不大。<br>
本人已改用passwall2，直接在xray中分流dns，结果更精准，开启fakedns降低延时，也不用安装其他插件。<br>
目前本人使用主路由+旁路网关，旁路网关设备安装passwall2，dnsmasq设置中关闭缓存(修改缓存值为0)，lan口自定义dns指向主路由;主路由安装smartdns并绑定53端口作为主dns。实现国内网站由smartdns解析，国外由xray分流解析。<br>
## 需要注意的是: <br>
如果你在主路由dhcp选项设置了旁路网关和及其dns，当设置smartdns为主dns时，smartdns会在dhcp选项中添加值通告dns指向主路由，当dhcp租约到期后，再次分配的dns会指向主路由，导致passwall2分流失效。<br>
## 解决方法:<br>
在主路由上注释掉/etc/init.d/smartdns中的97和123行:<br># uci -q add_list dhcp.lan.dhcp_option="6,$hostip"<br># uci -q del_list dhcp.lan.dhcp_option="6,$hostip"<br>
