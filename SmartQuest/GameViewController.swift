//
//  GameViewController.swift
//  SmartQuest
//
//  Created by セロラー on 2023/06/19.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //シーンの作成
        let scene = GameScene()
        
        //view ControllerのviewをSKviewとして取り出す
        let view = self.view as! SKView
        
        //fpsの表示
        view.showsFPS = true
        
        //ノード数の表示
        view.showsNodeCount = true
        
        //シーンのサイズをビューに合わせる
        scene.size = view.frame.size
        
        //ノードのphysicsbodyを表示する
        view.showsPhysics = true
        
        //重力の方向・強さを表示する
        view.showsFields = true
        
        //ビューをシーンに表示
        view.presentScene(scene)
        
        //マルチタップを無効にする
        view.isMultipleTouchEnabled = false
        
        
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
