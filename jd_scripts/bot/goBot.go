package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/boombuler/barcode"
	"github.com/boombuler/barcode/qr"
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	"image/png"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

var wg sync.WaitGroup

func main() {
	bot, err := tgbotapi.NewBotAPI("500000005:AAFh-92O*************8")
	if err != nil {
		log.Panic(err)
	}

	log.Printf("Telegram bot 已启动，Bot信息==> %s %s[%s]", bot.Self.FirstName, bot.Self.LastName, bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil {
			log.Printf("update.Message.Text is null")
			continue
		}

		if !update.Message.IsCommand() {
			log.Printf(update.Message.Text)
			continue
		}

		respMsg := tgbotapi.NewMessage(update.Message.Chat.ID, "")

		switch update.Message.Command() {
		case "help":
			go help(respMsg, bot)
		case "glc":
			go glc(update.Message.Chat.ID, bot)
		default:
			go unknownsCommand(respMsg, bot)
		}
	}
	wg.Wait()
}

func help(respMsg tgbotapi.MessageConfig, bot *tgbotapi.BotAPI) {
	//msg.Text = "睡了 " + strconv.FormatInt(sec, 10) + " 秒"
	respMsg.Text = "使用帮助说明"
	if _, err := bot.Send(respMsg); err != nil {
		log.Println(err)
	}

}

func unknownsCommand(respMsg tgbotapi.MessageConfig, bot *tgbotapi.BotAPI) {
	respMsg.Text = "请勿发送错误的指令消息"
	if _, err := bot.Send(respMsg); err != nil {
		log.Println(err)
	}
}
func glc(chatID int64, bot *tgbotapi.BotAPI) {

	sToken, cookie := getSToken()
	token, oklToken := getOKToken(sToken, cookie)

	log.Printf("%s>>>%s", token, oklToken)

	cookieUrl := fmt.Sprintf("https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=%s", token)
	//生成二维码
	qrCode, _ := qr.Encode(cookieUrl, qr.M, qr.Auto)
	//设置二维码分辨率
	qrCode, _ = barcode.Scale(qrCode, 400, 400)
	//创建一个输出文件
	file, _ := os.Create("/Users/akira-work/mybot/genQRCode1.png")
	defer file.Close()
	//写入文件
	png.Encode(file, qrCode)

	//需要传入绝对路径
	bytes, err1 := ioutil.ReadFile("/Users/akira-work/mybot/genQRCode1.png")
	if err1 != nil {
		log.Println(err1)
	}
	fileSend := tgbotapi.FileBytes{
		Name:  "genQRCode.png",
		Bytes: bytes,
	}

	respMsg := tgbotapi.NewPhotoUpload(chatID, fileSend)
	respMsg.Caption = "test"

	//respMsg.
	if _, err := bot.Send(respMsg); err != nil {
		log.Panic(err)
	}

}

func getSToken() (string, string) {
	var sToken string
	var cookie string

	timeStamp := time.Now().Unix()
	getUrl := fmt.Sprintf("https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%d&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport", timeStamp)

	getHeaders := http.Header{}
	getHeaders.Set("Connection", "Keep-Alive")
	getHeaders.Set("Content-Type", "application/x-www-form-urlencoded")
	getHeaders.Set("Accept", "application/json, text/plain, */*")
	getHeaders.Set("Accept-Language", "zh-cn")
	getHeaders.Set("Referer", fmt.Sprintf("https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%s&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport", timeStamp))
	getHeaders.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36")
	getHeaders.Set("Host", "plogin.m.jd.com")

	httpCode, cookies, body := httpDoGet(getUrl, getHeaders)
	if httpCode == 200 {
		var sTokenRespBody GetSTokenRespBody
		err := json.Unmarshal([]byte(body), &sTokenRespBody) // 反序列化
		if err != nil {
			fmt.Println("获取SToken请求报错Json %v", err)
		}
		sToken = sTokenRespBody.SToken
		log.Println(sTokenRespBody.SToken)

		log.Println(cookies)
		var guid string
		var lsid string
		var lstoken string
		for i := 0; i < len(cookies); i++ {
			var curCk *http.Cookie = cookies[i]
			if curCk.Name == "guid" && curCk.Value != "" {
				log.Printf("%s\t=%s", curCk.Name, curCk.Value)
				guid = curCk.Value
			}
			if curCk.Name == "lsid" && curCk.Value != "" {
				log.Printf("%s\t=%s", curCk.Name, curCk.Value)
				lsid = curCk.Value
			}
			if curCk.Name == "lstoken" && curCk.Value != "" {
				log.Printf("%s\t=%s", curCk.Name, curCk.Value)
				lstoken = curCk.Value
			}
		}
		cookie = fmt.Sprintf("guid=%s; lang=chs; lsid=%s; lstoken=%s; ", guid, lsid, lstoken)
	}
	return sToken, cookie
}

func getOKToken(sToken string, cookie string) (string, string) {

	var token string
	var oklToken string

	timeStamp := time.Now().Unix()

	postUrl := fmt.Sprintf("https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=%s&v=%d&remember=true", sToken, timeStamp)

	postHeader := http.Header{}
	postHeader.Set("Connection", "Keep-Alive")
	postHeader.Set("Content-Type", "application/x-www-form-urlencoded; Charset=UTF-8")
	postHeader.Set("Accept", "application/json, text/plain, */*")
	postHeader.Set("Cookie", cookie)
	postHeader.Set("Accept-Language", "zh-cn")
	postHeader.Set("Referer", fmt.Sprintf("https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=%d&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport", timeStamp))
	postHeader.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36")
	postHeader.Set("Host", "plogin.m.jd.com")

	postData := make(map[string]interface{})
	postData["lang"] = "chs"
	postData["appid"] = 300
	postData["returnurl"] = fmt.Sprintf("https://wqlogin2.jd.com/passport/LoginRedirect?state=%d&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action", timeStamp)
	postData["source"] = "wq_passport"
	bytesData, err := json.Marshal(postData)
	if err != nil {
		log.Println(err.Error())
	}

	httpCode, cookies, body := httpDoPost(postUrl, postHeader, bytes.NewReader(bytesData))
	if httpCode == 200 {
		var okTokenRespBody GetOKLTokenRespBody
		err := json.Unmarshal([]byte(body), &okTokenRespBody) // 反序列化
		if err != nil {
			fmt.Println("获取OKLToken请求报错Json %v", err)
		}
		token = okTokenRespBody.Token
		log.Println(okTokenRespBody.Token)
		log.Println(cookies)
		for i := 0; i < len(cookies); i++ {
			var curCk *http.Cookie = cookies[i]
			if curCk.Name == "okl_token" && curCk.Value != "" {
				log.Printf("%s\t=%s", curCk.Name, curCk.Value)
				oklToken = curCk.Value
			}
		}
	}
	return token, oklToken
}

func httpDoGet(url string, headers http.Header) (int, []*http.Cookie, string) {
	client := &http.Client{}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Println("生成request请求报错。。。")
	}
	req.Header = headers
	resp, err := client.Do(req)

	defer resp.Body.Close()

	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("获取请求结果Body报错。。。")
	}

	return resp.StatusCode, resp.Cookies(), string(respBody)
}
func httpDoPost(url string, headers http.Header, reqBody io.Reader) (int, []*http.Cookie, string) {
	client := &http.Client{}

	req, err := http.NewRequest("POST", url, reqBody)
	if err != nil {
		log.Println("生成request请求报错。。。")
	}
	req.Header = headers
	resp, err := client.Do(req)

	defer resp.Body.Close()

	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("获取请求结果Body报错。。。")
	}

	return resp.StatusCode, resp.Cookies(), string(respBody)
}

type GetSTokenRespBody struct {
	CountryCodeSwitch   bool   `json:"country_code_switch"`
	EnableSmsLogin      bool   `json:"enable_smslogin"`
	EnableUsernameLogin bool   `json:"enable_usernamelogin"`
	ErrCode             int    `json:"err_code"`
	ErrMsg              string `json:"err_msg"`
	JcapDomain          string `json:"jcap_domain"`
	Kepler              bool   `json:"kepler"`
	KpkeySwitch         bool   `json:"kpkey_switch"`
	LogoUrl             string `json:"logoUrl"`
	NeedAuth            bool   `json:"need_auth"`
	OnekeylogSwitch     bool   `json:"onekeylog_switch"`
	OnlyLogin           bool   `json:"only_login"`
	QblogSwitch         bool   `json:"qblog_switch"`
	RsaModulus          string `json:"rsa_modulus"`
	SToken              string `json:"s_token"`
	ShowApplelogin      bool   `json:"show_applelogin"`
	ShowCheckbox        bool   `json:"show_checkbox"`
	ShowJdpaylogin      bool   `json:"show_jdpaylogin"`
	ShowOtherlogin      bool   `json:"show_otherlogin"`
	ShowTitle           bool   `json:"show_title"`
	ShowWxlogin         bool   `json:"show_wxlogin"`
	Tpl                 string `json:"tpl"`
	UnmodifiedName      string `json:"unmodified_name"`
}
type GetOKLTokenRespBody struct {
	CheckLogin      int    `json:"checklogin"`
	ErrCode         int    `json:"errcode"`
	Message         string `json:"message"`
	NeedPoll        int    `json:"need_poll"`
	OnekeylogSwitch string `json:"onekeylog_switch"`
	OnekeylogUrl    string `json:"onekeylog_url"`
	OuState         int    `json:"ou_state"`
	Token           string `json:"token"`
}
