//
//  GameScene.swift
//  SmartQuest
//
//  Created by セロラー on 2023/06/19.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var enemyHPLabel: SKLabelNode? = nil
    var warriorHPLabel: SKLabelNode? = nil
    var knightHPLabel: SKLabelNode? = nil
    var priestHPLabel: SKLabelNode? = nil
    var mageHPLabel: SKLabelNode? = nil
    
    //各種サイズ格納変数
    var topSize = CGSize(width: 0, height: 0)       //天井のサイズ
    var wallSize = CGSize(width: 0, height: 0)      //壁のサイズ
    var floorSize = CGSize(width: 0, height: 0)     //床のサイズ
    var cueSize = CGSize(width: 0, height: 0)       //キューのサイズ
    var notchHeight: CGFloat = 0.0                  //ノッチ部分の高さを格納する変数
    var stageSize = CGSize(width: 0, height: 0)     //ステージのサイズ
    var statusSize = CGSize(width: 0, height: 0)    //ステータス画面のサイズ
    var stagePositionZero = CGPoint(x: 0, y: 0)     //ステージの原点座標
    
    
    //発射地点のノード
    var launchNode: SKFieldNode!
    
    //各種パラメーター格納用変数
    
    var sizeDefault_Caracter = CGSize(width: 0, height: 0)  //キャラクターの基本サイズ
    var frictionDefault_Caracter = 0.1                      //摩擦係数
    var birthPosition = CGPoint(x: 0, y: 0)                 //最初のキャラが生成される座標
    
    let restitution_Wall: CGFloat = 0.0                    //壁の反発係数
    let restitution_Caracter: CGFloat = 0.3                 //キャラクターの反発係数
    let restitution_cue: CGFloat = 0.5                      //キューの反発係数
    let restitution_pin: CGFloat = 0.9                      //ピンの反発係数
    let restitution_gate: CGFloat = 1.0                     //ゲートの反発係数
    let restitution_enemy: CGFloat = 1.0
    let restitution_damage: CGFloat = 1.0
    
    let friction_cue: CGFloat = 1.0                         //キューの摩擦係数
    let friction_pin: CGFloat = 0.0                         //ピンの摩擦係数
    let friction_wall: CGFloat = 0.3
    let friction_enemy: CGFloat = 1.0
    //カテゴリビットマスクの設定
    struct CategoryBitMask {
        static let character: UInt32 = 0x1 << 0
        static let wall: UInt32 = 0x1 << 1
        static let floor: UInt32 = 0x1 << 2
        static let launch: UInt32 = 0x1 << 3
        static let stage: UInt32 = 0x1 << 4
        static let cue: UInt32 = 0x1 << 5
        static let floorBottom: UInt32 = 0x1 << 6
        static let gate: UInt32 = 0x1 << 7
        static let damage: UInt32 = 0x1 << 8
        static let enemy: UInt32 = 0x1 << 9
    }
    
    //共通設定
    let gravityStrength:Float = 9.8 / 2   //重力の強さ
    
    
    
    var cue: SKSpriteNode!
    var originalPosition: CGPoint! //タップされた座標
    var firstCuePosition: CGPoint! //タップされた時のキューの座標
    
    //ピンテクスチャの生成
    let pinTexture = SKTexture(imageNamed: "pin")
    
    
    //各キャラクターのステータス
    //戦士
    var HP_warrior: Int32 = 100
    let HP_warrior_default: Int32 = 100
    var ATK_warrior: Int32 = 30
    
    //剣士
    var HP_knight: Int32 = 80
    let HP_knight_default: Int32 = 80
    var ATK_knight: Int32 = 50
    
    //魔法使い
    var HP_mage: Int32 = 50
    let HP_mage_default: Int32 = 50
    var ATK_mage: Int32 = 20
    
    //僧侶
    var HP_priest: Int32 = 60
    let HP_priest_default: Int32 = 60
    var ATK_priest: Int32 = 10
    
    //敵
    var HP_enemy: Int32 = 300
    let HP_enemy_default: Int32 = 300
    var ATK_enemy: Int32 = 30
    
    //ダメージ判定
    var ATK_damage: Int32 = 10

    //死亡判定
    var death: Int32 = 1
    
    
    //ピンを配置できる座標を格納するための２次元配列
    var pinPositions: [[CGPoint]] = []
    //実際に配置するピンの座標を選択して格納する配列
    var selectedPositions: [CGPoint] = []
    //ダメージを配置する座標
    var damagePositions: [CGPoint] = []
    //ステージに必ず配置されるピンの座標
    var defaultPinPositions: [CGPoint] = []
    

    var debug = 0   //デバッグ状態の判定 0 = デバッグモードON　0 < OFF


    var stageSelect_size = CGSize(width: 0, height: 0)
    
    var nowPlace: String = "nil"    //現在動作中の画面の状態を判定する
    
    var stage1: UIButton!
    var stage2: UIButton!
    var stage3: UIButton!
    
    
    override func didMove(to view: SKView) {
        //ノッチ部分のサイズを取得する
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let statusBarManager = windowScene.statusBarManager {
                let statusBarFrame = statusBarManager.statusBarFrame
                notchHeight = statusBarFrame.size.height
            }
        }
        
        //ステータス画面のスペースを確保する
        statusSize = CGSize(width: self.size.width, height: self.size.height / 10)
        //ステージのサイズを取得する
        stageSize = CGSize(width: self.size.width, height: self.size.height - statusSize.height)
        //ステージの原点座標を設定
        stagePositionZero = CGPoint(x: 0, y: statusSize.height)
        
        
        
        //各キャラの共通設定
        sizeDefault_Caracter = CGSize(width: stageSize.width / 15, height: stageSize.width / 15)   //サイズ
        birthPosition = CGPoint(x: sizeDefault_Caracter.width * 1.1, y: SKTexture(imageNamed: "floor").size().height / 2 + stagePositionZero.y)

        //背景を黄緑一色にする
        let yellowGreenColor = UIColor(red: 0.68, green: 0.89, blue: 0.38, alpha: 1.0)
        self.backgroundColor = yellowGreenColor
        
        physicsWorld.gravity = CGVector(dx: 0, dy: Int(-gravityStrength))
        //SKPhysicsContactDelegateを有効にしてノード同士が衝突した際にcontactメソッドが呼び出されるようにする
        physicsWorld.contactDelegate = self
        
        
        //pinPositions[0][0]~pinPositions[11][11]までの144個の座標を格納するための２次元配列を作成
        //それぞれの座標はステージサイズを縦横に12分割した座標
        
        //divisionCountの数だけステージサイズを分割して座標をpinPositionsに登録する
        let divisionCount = 60
        let divisionWidth = stageSize.width / CGFloat(divisionCount)
        let divisionHeight = stageSize.height / CGFloat(divisionCount)

        print("divisionWidth=\(divisionWidth)")
        for i in 0..<divisionCount {
            var innerArray: [CGPoint] = []
            for j in 0..<divisionCount {
                let x = CGFloat(j) * divisionWidth + divisionWidth / 2
                let y = CGFloat(i) * divisionHeight + divisionHeight / 2 + stagePositionZero.y + sizeDefault_Caracter.height
                let pinPoint = CGPoint(x: x, y: y)
                innerArray.append(pinPoint)
            }
            pinPositions.append(innerArray)
            print("座標登録\(innerArray)")
        }
        
        //デフォルトピンの座標登録
        let defaultPin1 = CGPoint(x: pinPositions[43][1].x, y: pinPositions[43][1].y)  //ループの先のピン1
        let defaultPin2 = CGPoint(x: pinPositions[43][2].x, y: pinPositions[43][1].y)  //ループの先のピン2
        let defaultPin3 = CGPoint(x: pinPositions[43][3].x, y: pinPositions[43][1].y)  //ループの先のピン3
        let defaultPin4 = CGPoint(x: pinPositions[0][53].x, y: pinPositions[1][51].y)   //ステージ右下の引っ掛かり防止用
        defaultPinPositions.append(defaultPin1)
        defaultPinPositions.append(defaultPin2)
        defaultPinPositions.append(defaultPin3)
        defaultPinPositions.append(defaultPin4)
        
        stageSelect_size = CGSize(width: self.size.width / 3, height: self.size.height / 6)
        
        //ピンを設置する座標を確認するための格子線(デバッグ用)

        //pinLattice()
        
        OP_menu()
    }
    
    func OP_menu(){
        let OP_text = SKLabelNode(text: "スマートクエスト")
        let TapStart = SKLabelNode(text: "タップでスタート")
        
        OP_text.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        TapStart.position = CGPoint(x: OP_text.position.x, y: self.size.height / 3)
        
        self.addChild(OP_text)
        self.addChild(TapStart)
        nowPlace = "OP画面"
    }
    
    func stageSelect() {
        let buttonSize = stageSelect_size

        stage1 = UIButton(frame: CGRect(x: self.size.width / 2, y: self.size.height - stageSelect_size.height, width: stageSelect_size.width, height: stageSelect_size.height))
        stage1.backgroundColor = UIColor.blue
        stage1.layer.masksToBounds = true
        stage1.layer.cornerRadius = 20.0
        stage1.setTitle("1-1", for: .normal)
        stage1.setTitleColor(UIColor.white, for: .normal)
        stage1.tag = 1
        stage1.addTarget(self, action: #selector(stage1Tapped(sender:)), for: .touchUpInside)
        
        stage2 = UIButton(frame: CGRect(x: self.size.width / 2, y: self.size.height - stageSelect_size.height * 2, width: stageSelect_size.width, height: stageSelect_size.height))
        stage2.backgroundColor = UIColor.blue
        stage2.layer.masksToBounds = true
        stage2.layer.cornerRadius = 20.0
        stage2.setTitle("1-2", for: .normal)
        stage2.setTitleColor(UIColor.white, for: .normal)
        stage2.tag = 3
        stage2.addTarget(self, action: #selector(stage2Tapped(sender:)), for: .touchUpInside)
        
        stage3 = UIButton(frame: CGRect(x: self.size.width / 2, y: self.size.height - stageSelect_size.height * 3, width: stageSelect_size.width, height: stageSelect_size.height))
        stage3.backgroundColor = UIColor.blue
        stage3.layer.masksToBounds = true
        stage3.layer.cornerRadius = 20.0
        stage3.setTitle("1-3", for: .normal)
        stage3.setTitleColor(UIColor.white, for: .normal)
        stage3.tag = 3
        stage3.addTarget(self, action: #selector(stage3Tapped(sender:)), for: .touchUpInside)
        
        
        nowPlace = "ステージセレクト"
        
        self.view!.addSubview(stage1)
        self.view!.addSubview(stage2)
        self.view!.addSubview(stage3)
    }
    
    //各種壁の配置
    func setWall() {
        
        //発射地点に重力を発生させるノード
        launchNode = SKFieldNode.linearGravityField(withVector: vector_float3(x: 1, y: 0, z: 0))
        launchNode.strength = gravityStrength / 2
        launchNode.position = CGPoint(x: stageSize.width - sizeDefault_Caracter.width / 2, y: sizeDefault_Caracter.height / 2 + stagePositionZero.y)
        launchNode.physicsBody?.categoryBitMask = CategoryBitMask.launch
        addChild(launchNode)
        
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.linear
        let wallRight = SKSpriteNode(texture: wallTexture)
        let wallLeft = SKSpriteNode(texture: wallTexture)
        let wallLail = SKSpriteNode(texture: wallTexture)
        
        let topTexture = SKTexture(imageNamed: "top")
        topTexture.filteringMode = SKTextureFilteringMode.linear
        let top = SKSpriteNode(texture: topTexture)
        
        let floorTexture = SKTexture(imageNamed: "floor")
        floorTexture.filteringMode = SKTextureFilteringMode.linear
        let floor = SKSpriteNode(texture: floorTexture)
        let floorBottom = SKSpriteNode(texture: floorTexture)
        
        wallRight.size = CGSize(width: wallRight.size.width, height: stageSize.height * 1.1)
        wallSize = wallRight.size   //壁のサイズを登録
        wallRight.physicsBody = SKPhysicsBody(rectangleOf: wallRight.size)
        wallRight.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallRight.physicsBody?.restitution = restitution_Wall
        wallRight.physicsBody?.friction = friction_wall
        wallRight.position = CGPoint(x: stageSize.width + wallSize.width / 2, y: stageSize.height / 2)
        wallRight.physicsBody?.isDynamic = false
        
        
        
        wallLeft.size = CGSize(width: wallLeft.size.width, height: stageSize.height * 1.1)
        wallLeft.physicsBody = SKPhysicsBody(rectangleOf: wallLeft.size)
        wallLeft.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallLeft.physicsBody?.restitution = restitution_Wall
        wallLeft.physicsBody?.friction = friction_wall
        wallLeft.position = CGPoint(x: -wallSize.width / 2, y: stageSize.height / 2)
        wallLeft.physicsBody?.isDynamic = false
        
        top.size = CGSize(width: stageSize.width + wallSize.width, height: top.size.height * stageSize.width / top.size.width)
        top.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "top"), size: CGSize(width: top.size.width, height: top.size.height))
        top.physicsBody?.categoryBitMask = CategoryBitMask.wall
        top.physicsBody?.isDynamic = false
        top.physicsBody?.friction = 0
        top.physicsBody?.restitution = 0.5
        top.position = CGPoint(x: stageSize.width / 2, y: stageSize.height - top.size.height / 2 - notchHeight + stagePositionZero.y)
        
        topSize = top.size  //天井のサイズを登録
        
        //画面一番下の床
        floorBottom.size = CGSize(width: floorTexture.size().width, height: floorTexture.size().height)
        floorBottom.physicsBody = SKPhysicsBody(rectangleOf: floorBottom.size)
        floorBottom.physicsBody?.categoryBitMask = CategoryBitMask.floorBottom
        floorBottom.physicsBody?.contactTestBitMask = CategoryBitMask.character
        floorBottom.physicsBody?.isDynamic = false
        floorBottom.physicsBody?.restitution = restitution_Wall
        floorBottom.physicsBody?.friction = friction_wall
        floorBottom.position = CGPoint(x: floorBottom.size.width / 2, y:  stagePositionZero.y)
        floorBottom.name = "床"
        
        floorSize = floorBottom.size    //床のサイズを登録
        
        wallLail.size = CGSize(width: wallLail.size.width / 2, height: stageSize.height - (top.size.height + notchHeight + sizeDefault_Caracter.height * 1.01))
        wallLail.physicsBody = SKPhysicsBody(rectangleOf: wallLail.size)
        wallLail.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallLail.physicsBody?.restitution = restitution_Wall
        //発射レール壁の位置は下と右にボールの通り道ができるように配置
        wallLail.position = CGPoint(x: stageSize.width - sizeDefault_Caracter.width * 1.2, y: wallLail.size.height / 2 + sizeDefault_Caracter.height * 1.1 + floorBottom.size.height / 2 + stagePositionZero.y)
        wallLail.physicsBody?.isDynamic = false
        
        //ステージ下の落下判定床
        floor.size = CGSize(width: stageSize.width, height: floor.size.height / 5)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = CategoryBitMask.floor
        floor.physicsBody?.isDynamic = false
        floor.position = CGPoint(x: stageSize.width / 2 - (stageSize.width - wallLail.position.x), y: wallLail.position.y - wallLail.size.height / 2 + floor.size.height / 2)
        floor.name = "落下判定"
        
        //ゲートの設置
        //太さは発射レール壁の半分、長さはキャラクターの直径の√2倍
        let gate = SKSpriteNode(color: UIColor.magenta, size: CGSize(width: wallLail.size.width / 2, height: sizeDefault_Caracter.height * sqrt(2)))
        gate.zRotation = -CGFloat.pi / 4     //45度傾ける
        gate.position = CGPoint(x: wallLail.position.x + sizeDefault_Caracter.width / 2, y: wallLail.position.y + wallLail.size.height / 2 + sizeDefault_Caracter.height / 2)
        gate.physicsBody = SKPhysicsBody(rectangleOf: gate.size)
        gate.physicsBody?.isDynamic = false
        gate.physicsBody?.categoryBitMask = CategoryBitMask.gate
        gate.physicsBody?.contactTestBitMask = CategoryBitMask.character
        gate.physicsBody?.collisionBitMask = 0
        gate.physicsBody?.friction = 0.7
        gate.physicsBody?.restitution = restitution_gate
        gate.name = "ゲート"
        
        //キューの設置
        let cueTexture = SKTexture(imageNamed: "que")
        cueTexture.filteringMode = SKTextureFilteringMode.linear
        cue = SKSpriteNode(texture: cueTexture, size: CGSize(width: sizeDefault_Caracter.width * 0.8, height: stageSize.height / 2))
        
        cue.physicsBody = SKPhysicsBody(texture: cueTexture, size: cue.size)
        cue.physicsBody?.isDynamic = true
        cue.physicsBody?.affectedByGravity = false  //重力の影響を受けなくする
        cue.physicsBody?.fieldBitMask = 0
        cue.physicsBody?.friction = friction_cue    //摩擦係数
        cue.physicsBody?.restitution = restitution_cue //反発係数
        cue.physicsBody?.allowsRotation = false
        cue.physicsBody?.categoryBitMask = CategoryBitMask.wall
        cue.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall
        cue.position = CGPoint(x: stageSize.width - sizeDefault_Caracter.width / 2, y: -cue.size.height / 3 + stagePositionZero.y)
        cue.name = "キュー"
        
        
        let cue_joint = SKSpriteNode(color: UIColor.clear, size: sizeDefault_Caracter)
        cue_joint.position = cue.position
        cue_joint.name = "ジョイント"
        //物理演算プロパティ
        cue_joint.physicsBody = SKPhysicsBody()
        cue_joint.physicsBody?.isDynamic = false
        cue_joint.physicsBody?.categoryBitMask = CategoryBitMask.cue
        
        //キューを固定するジョイント(バネ)
        let joint = SKPhysicsJointSpring.joint(withBodyA: cue.physicsBody!, bodyB: cue_joint.physicsBody!, anchorA: cue.position, anchorB: cue_joint.position)
        
        //伸縮の周期を設定する
        joint.frequency = 2.0
        
        //伸縮の減衰を設定する
        joint.damping = 0.5
        
        cueSize = cue.size  //キューのサイズを登録
        
        
        self.addChild(wallRight)
        self.addChild(wallLeft)
        self.addChild(wallLail)
        self.addChild(top)
        self.addChild(floorBottom)
        self.addChild(floor)
        self.addChild(gate)
        self.addChild(cue)
        self.addChild(cue_joint)
        self.physicsWorld.add(joint)
        
    }
    
    //ピンの設置
    func setPin() {
        //ピンの色を設定
        let pinColor = UIColor.gray
        print("座標一覧\(pinPositions)")

        
        let pinCount = selectedPositions.count   //生成するピンの個数
        let defaultPinCount = defaultPinPositions.count //デフォルトピンの個数
        
        //ピンを生成
        for i in 0..<pinCount {
            let pin = SKSpriteNode(texture: pinTexture, size: CGSize(width: sizeDefault_Caracter.width / 5, height: sizeDefault_Caracter.height / 5))
            pin.physicsBody = SKPhysicsBody(circleOfRadius: pin.size.width / 2)
            pin.physicsBody?.isDynamic = false
            pin.physicsBody?.restitution = restitution_pin  //反発係数
            pin.physicsBody?.friction = friction_pin        //摩擦係数
            pin.name = "Pin\(i+1+defaultPinCount)" // ピンに番号を振る
            pin.position = selectedPositions[i]
            print(pin.position)
            pin.color = pinColor        //ピンの色を設定
            pin.colorBlendFactor = 1.0  //カラーブレンドを有効にすることで色が反映される
            
            self.addChild(pin)
        }
        
        //デフォルトピンを生成
        
        for i in 0..<defaultPinCount {
            let pin = SKSpriteNode(texture: pinTexture, size: CGSize(width: sizeDefault_Caracter.width / 5, height: sizeDefault_Caracter.height / 5))
            pin.physicsBody = SKPhysicsBody(circleOfRadius: pin.size.width / 2)
            pin.physicsBody?.isDynamic = false
            pin.physicsBody?.restitution = restitution_pin  //反発係数
            pin.physicsBody?.friction = friction_pin        //摩擦係数
            pin.name = "Pin\(i+1)" // ピンに番号を振る
            pin.position = defaultPinPositions[i]
            print(pin.position)
            pin.color = pinColor        //ピンの色を設定
            pin.colorBlendFactor = 1.0  //カラーブレンドを有効にすることで色が反映される
            
            self.addChild(pin)
        }
        
    }

    //キャラの生成
    func makeCharacter() {
        
        let warriorTexture = SKTexture(imageNamed: "warrior")
        warriorTexture.filteringMode = SKTextureFilteringMode.linear
        let warrior = SKSpriteNode(texture: warriorTexture)
        let knightTexture = SKTexture(imageNamed: "knight")
        knightTexture.filteringMode = SKTextureFilteringMode.linear
        let knight = SKSpriteNode(texture: knightTexture)
        let priestTexture = SKTexture(imageNamed: "priest")
        priestTexture.filteringMode = SKTextureFilteringMode.linear
        let priest = SKSpriteNode(texture: priestTexture)
        let mageTexture = SKTexture(imageNamed: "mage")
        mageTexture.filteringMode = SKTextureFilteringMode.linear
        let mage = SKSpriteNode(texture: mageTexture)
        
        //戦士
        warrior.size = sizeDefault_Caracter
        warrior.physicsBody = SKPhysicsBody(circleOfRadius: warrior.size.width / 2.0)
        warrior.physicsBody?.isDynamic = true
        warrior.physicsBody?.friction = frictionDefault_Caracter
        warrior.physicsBody?.fieldBitMask = 0   //フィールドビットマスク＝0で発射地点に吸い寄せられなくなる
        warrior.physicsBody?.categoryBitMask = CategoryBitMask.character
        warrior.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        warrior.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue | CategoryBitMask.damage
        warrior.position = birthPosition
        warrior.name = "戦士"
        
        HP_warrior = HP_warrior_default
        
        //剣士
        knight.size = sizeDefault_Caracter
        knight.physicsBody = SKPhysicsBody(circleOfRadius: knight.size.width / 2.0)
        knight.physicsBody?.isDynamic = true
        knight.physicsBody?.friction = frictionDefault_Caracter
        knight.physicsBody?.fieldBitMask = 0
        knight.physicsBody?.categoryBitMask = CategoryBitMask.character
        knight.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        knight.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue | CategoryBitMask.damage
        knight.position = CGPoint(x: birthPosition.x + warrior.size.width, y: birthPosition.y)
        knight.name = "剣士"
        
        HP_knight = HP_knight_default
        
        //僧侶
        priest.size = sizeDefault_Caracter
        priest.physicsBody = SKPhysicsBody(circleOfRadius: priest.size.width / 2.0)
        priest.physicsBody?.isDynamic = true
        priest.physicsBody?.friction = frictionDefault_Caracter
        priest.physicsBody?.fieldBitMask = 0
        priest.physicsBody?.categoryBitMask = CategoryBitMask.character
        priest.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        priest.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue | CategoryBitMask.damage
        priest.position = CGPoint(x: birthPosition.x + warrior.size.width * 2, y: birthPosition.y)
        priest.name = "僧侶"
        
        HP_priest = HP_priest_default
        
        //魔法使い
        mage.size = sizeDefault_Caracter
        mage.physicsBody = SKPhysicsBody(circleOfRadius: mage.size.width / 2.0)
        mage.physicsBody?.isDynamic = true
        mage.physicsBody?.friction = frictionDefault_Caracter
        mage.physicsBody?.fieldBitMask = 0
        mage.physicsBody?.categoryBitMask = CategoryBitMask.character
        mage.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        mage.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue
        mage.position = CGPoint(x: birthPosition.x + warrior.size.width * 3, y: birthPosition.y)
        mage.name = "魔法使い"
        
        HP_mage = HP_mage_default
        
        addChild(warrior)
        addChild(knight)
        addChild(priest)
        addChild(mage)
    }
    
    //敵の生成
    func setEnemy() {
        let enemyTexture = SKTexture(imageNamed: "enemy")
        enemyTexture.filteringMode = SKTextureFilteringMode.linear
        let enemy = SKSpriteNode(texture: enemyTexture)
        
        enemy.size = CGSize(width: sizeDefault_Caracter.width * 5, height: sizeDefault_Caracter.height * 5)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.contactTestBitMask = CategoryBitMask.character
        enemy.physicsBody?.collisionBitMask = CategoryBitMask.character
        enemy.physicsBody?.friction = friction_enemy
        enemy.physicsBody?.restitution = restitution_enemy
        enemy.position = CGPoint(x: stageSize.width / 2, y: stageSize.height / 4 + stagePositionZero.y)
        enemy.name = "敵"
        
        HP_enemy = HP_enemy_default
        
        enemyHPLabel = SKLabelNode(text: "HP:\(HP_enemy)")
        enemyHPLabel!.fontColor = UIColor.black
        enemyHPLabel!.position = CGPoint(x: enemy.position.x, y: enemy.position.y - enemy.size.height / 2)
        
        self.addChild(enemy)
        self.addChild(enemyHPLabel!)
    }
    
    //ダメージ判定の生成
    func setDamage() {
        let damageTexture = SKTexture(imageNamed: "damage")
        damageTexture.filteringMode = SKTextureFilteringMode.linear
        
        //各ダメージ判定のサイズリスト
        let damageSizes: [CGSize] = [
            CGSize(width: wallSize.width / 5, height: stageSize.height / 10),
            CGSize(width: wallSize.width / 5, height: stageSize.height / 10),
            CGSize(width: wallSize.width / 2, height: wallSize.width / 2),
            CGSize(width: wallSize.width / 2, height: wallSize.width / 2),
            CGSize(width: wallSize.width / 2, height: wallSize.width / 2)
        ]
        
        
        
        let damageCount = damagePositions.count    //生成するピンの個数
        //ダメージ判定を生成
        for i in 0..<damageCount {
            let damage = SKSpriteNode(texture: damageTexture)
            damage.size = damageSizes[i]
            damage.physicsBody = SKPhysicsBody(rectangleOf: damage.size)
            damage.physicsBody?.isDynamic = false
            damage.physicsBody?.categoryBitMask = CategoryBitMask.damage
            damage.physicsBody?.collisionBitMask = CategoryBitMask.character
            damage.physicsBody?.contactTestBitMask = CategoryBitMask.character
            damage.physicsBody?.restitution = restitution_damage  //反発係数
            damage.physicsBody?.friction = friction_wall        //摩擦係数
            damage.name = "ダメージ" // ダメージ判定に番号を振る
            damage.position = damagePositions[i]
            
            self.addChild(damage)
        }
        
        
    }
    
    //ステータスメニューの構成
    func setStatus() {
        let statusMenuSize = CGRect(x: 0, y: 0, width: statusSize.width - sizeDefault_Caracter.width * 1.1, height: statusSize.height)
        let renderer = UIGraphicsImageRenderer(size: statusMenuSize.size)
        let textureImage = renderer.image { context in
            UIColor.black.setFill() // 長方形の塗りつぶし色を指定
            context.fill(statusMenuSize) // 指定したフレーム内に長方形を描画
        }
        //テクスチャイメージをSKテクスチャに変換
        let statusMenuTexture = SKTexture(image: textureImage)
        let statusMenuNode = SKSpriteNode(texture: statusMenuTexture)
        statusMenuNode.position = CGPoint(x: statusMenuNode.size.width / 2, y: statusMenuNode.size.height / 2)
        
        //キャラクターアイコンサイズ
        let iconSize = CGSize(width: statusMenuNode.size.width / 4 * 0.8, height: statusMenuNode.size.width / 4 * 0.8)
        let iconPosition = CGPoint(x: statusMenuNode.size.width / 4, y: statusMenuNode.size.height / 2)
        
        let warriorTexture = SKTexture(imageNamed: "warrior")
        warriorTexture.filteringMode = SKTextureFilteringMode.nearest
        let warrior = SKSpriteNode(texture: warriorTexture)
        warrior.size = iconSize
        warrior.position = CGPoint(x: iconPosition.x * 0.5, y: iconPosition.y)
        let knightTexture = SKTexture(imageNamed: "knight")
        knightTexture.filteringMode = SKTextureFilteringMode.nearest
        let knight = SKSpriteNode(texture: knightTexture)
        knight.size = iconSize
        knight.position = CGPoint(x: iconPosition.x * 1.5, y: iconPosition.y)
        let priestTexture = SKTexture(imageNamed: "priest")
        priestTexture.filteringMode = SKTextureFilteringMode.nearest
        let priest = SKSpriteNode(texture: priestTexture)
        priest.size = iconSize
        priest.position = CGPoint(x: iconPosition.x * 2.5, y: iconPosition.y)
        let mageTexture = SKTexture(imageNamed: "mage")
        mageTexture.filteringMode = SKTextureFilteringMode.nearest
        let mage = SKSpriteNode(texture: mageTexture)
        mage.size = iconSize
        mage.position = CGPoint(x: iconPosition.x * 3.5, y: iconPosition.y)
        
        warriorHPLabel = SKLabelNode(text: "HP\n\(HP_warrior)")
        warriorHPLabel?.numberOfLines = 2
        warriorHPLabel!.fontColor = UIColor.orange
        warriorHPLabel?.fontSize = warrior.size.width / 4
        warriorHPLabel?.fontName = "Didot-Bold"
        warriorHPLabel!.position = CGPoint(x: warrior.position.x, y: warrior.position.y - warrior.size.height / 2)
        
        knightHPLabel = SKLabelNode(text: "HP\n\(HP_knight)")
        knightHPLabel?.numberOfLines = 2
        knightHPLabel!.fontColor = UIColor.orange
        knightHPLabel?.fontSize = knight.size.width / 4
        knightHPLabel?.fontName = "Didot-Bold"
        knightHPLabel!.position = CGPoint(x: knight.position.x, y: knight.position.y - knight.size.height / 2)
        
        priestHPLabel = SKLabelNode(text: "HP\n\(HP_priest)")
        priestHPLabel?.numberOfLines = 2
        priestHPLabel!.fontColor = UIColor.orange
        priestHPLabel?.fontSize = priest.size.width / 4
        priestHPLabel?.fontName = "Didot-Bold"
        priestHPLabel!.position = CGPoint(x: priest.position.x, y: priest.position.y - priest.size.height / 2)
        
        mageHPLabel = SKLabelNode(text: "HP\n\(HP_mage)")
        mageHPLabel?.numberOfLines = 2
        mageHPLabel!.fontColor = UIColor.orange
        mageHPLabel?.fontSize = mage.size.width / 4
        mageHPLabel?.fontName = "Didot-Bold"
        mageHPLabel!.position = CGPoint(x: mage.position.x, y: mage.position.y - mage.size.height / 2)
        
        self.addChild(statusMenuNode)
        self.addChild(warrior)
        self.addChild(knight)
        self.addChild(mage)
        self.addChild(priest)
        
        self.addChild(warriorHPLabel!)
        self.addChild(knightHPLabel!)
        self.addChild(priestHPLabel!)
        self.addChild(mageHPLabel!)
        
    }
    
    func stage1_1() {
        
        //一度selectedPositionsを空にする
        selectedPositions.removeAll()
        //各ピンの座標リストpinPositions[0][0]~[59][59]
        selectedPositions = [
            pinPositions[50][19],
            pinPositions[50][24],
            pinPositions[50][29],
            pinPositions[50][34],
            pinPositions[50][39],
            pinPositions[47][22],
            pinPositions[47][27],
            pinPositions[47][32],
            pinPositions[47][37],
            pinPositions[47][42],
            pinPositions[47][17],
            pinPositions[17][17],
            pinPositions[18][15],
            pinPositions[19][14],
            pinPositions[20][13],
            pinPositions[21][12],
            pinPositions[22][11],
            pinPositions[17][43],
            pinPositions[18][45],
            pinPositions[19][46],
            pinPositions[20][47],
            pinPositions[21][48],
            pinPositions[22][49],
            pinPositions[23][50],
            pinPositions[24][51],
            pinPositions[25][52],
            pinPositions[26][53],
            pinPositions[20][41],
            pinPositions[21][42],
            pinPositions[22][43],
            pinPositions[23][44],
            pinPositions[24][45],
            pinPositions[25][46],
            pinPositions[26][47],
            pinPositions[27][48],
            pinPositions[28][49],
            pinPositions[29][49],
            pinPositions[30][49],
            pinPositions[31][49],
            pinPositions[32][49],
            pinPositions[33][49],
            pinPositions[34][49],
            pinPositions[35][49],
            pinPositions[36][49],
            pinPositions[37][49],
            pinPositions[38][49],
            pinPositions[39][49],
            pinPositions[40][49],
            pinPositions[41][49],
            pinPositions[42][49],
            pinPositions[23][28],
            pinPositions[24][28],
            pinPositions[25][28],
            pinPositions[26][28],
            pinPositions[27][27],
            pinPositions[28][27],
            pinPositions[23][32],
            pinPositions[24][32],
            pinPositions[25][32],
            pinPositions[26][32],
            pinPositions[27][33],
            pinPositions[28][33],
            pinPositions[31][30],
            pinPositions[31][29],
            pinPositions[31][31],
            pinPositions[32][30],
            pinPositions[33][30],
            pinPositions[45][10],
            pinPositions[45][15],
            pinPositions[45][25],
            pinPositions[45][20],
            pinPositions[45][30],
            pinPositions[45][35],
            pinPositions[45][40],
            pinPositions[45][45],
            pinPositions[45][50],
            pinPositions[42][10],
            pinPositions[43][15],
            pinPositions[42][10],
            pinPositions[42][20],
            pinPositions[42][30],
            pinPositions[43][35],
            pinPositions[42][40],
            pinPositions[43][25],
            pinPositions[40][15],
            pinPositions[40][25],
            pinPositions[40][35],
            pinPositions[43][49]
        ]
        
        //各ダメージ判定の座標リスト
        damagePositions = [
            pinPositions[5][0],
            pinPositions[5][54],
            pinPositions[25][5],
            pinPositions[32][15],
            pinPositions[18][42]
        ]
        
        
        setWall()
        makeCharacter()
        setPin()
        setEnemy()
        setDamage()
        setStatus()
        
        nowPlace = "ステージ"
    }
    
    //ピン配置の目安のための格子線
    func pinLattice() {
        let debugNode = SKSpriteNode()
        debugNode.name = "デバッグノード"
        let dotTexture = SKTexture(imageNamed: "pin")
        let dotSize = CGSize(width: 1, height: 1)

        for i in 0..<60 {
            for j in 0..<60 {
                let point = pinPositions[i][j]
                var dotSize = CGSize(width: 1, height: 1)

                if [10, 20, 30, 40, 50].contains(i) || [10, 20, 30, 40, 50].contains(j) {
                    dotSize = CGSize(width: 5, height: 5)
                }
                
                if [5, 15, 25, 35, 45, 55].contains(i) || [5, 15, 25, 35, 45, 55].contains(j) {
                    dotSize = CGSize(width: 3, height: 3)
                }

                let dot = SKSpriteNode(texture: dotTexture, size: dotSize)
                dot.color = .white
                dot.colorBlendFactor = 1.0
                dot.position = point
                dot.name = "ドット"

                debugNode.addChild(dot)
            }
        }

        self.addChild(debugNode)
        debug = 1

    }
    
    //ノードの衝突時に呼び出されるメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact = \(String(describing: contact.bodyA.node?.name)) : \(String(describing: contact.bodyB.node?.name))")
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        var characterNode: SKNode
        var partnerNode: SKNode
        
        //キャラクターが他のノードと衝突した場合の処理
        if nodeA?.physicsBody?.categoryBitMask == CategoryBitMask.character || nodeB?.physicsBody?.categoryBitMask == CategoryBitMask.character {
            //キャラクター側と衝突先側それぞれに名前をつける
            if nodeA?.physicsBody?.categoryBitMask == CategoryBitMask.character {
                characterNode = nodeA!
                partnerNode = nodeB!
            }else{
                characterNode = nodeB!
                partnerNode = nodeA!
            }
            //キャラクターが床と衝突した時
            if partnerNode.name == "床" {
                //キャラクターが落下判定床をすり抜けないようにする
                characterNode.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue
                characterNode.physicsBody?.fieldBitMask = CategoryBitMask.launch
            }
            
            //キャラクターがダメージに触れた時
            if partnerNode.name == "ダメージ" {
                if characterNode.name == "戦士" {
                    HP_warrior -= ATK_damage
                    death = HP_warrior
                    if HP_warrior <= 0 {
                        warriorHPLabel?.text = "HP\n0"
                    }else{
                        warriorHPLabel?.text = "HP\n\(HP_warrior)"
                    }
                }else if characterNode.name == "剣士" {
                    HP_knight -= ATK_damage
                    death = HP_knight
                    if HP_knight <= 0 {
                        knightHPLabel?.text = "HP\n0"
                    }else{
                        knightHPLabel?.text = "HP\n\(HP_knight)"
                    }
                }else if characterNode.name == "魔法使い" {
                    HP_mage -= ATK_damage
                    death = HP_mage
                    if HP_mage <= 0 {
                        mageHPLabel?.text = "HP\n0"
                    }else{
                        mageHPLabel?.text = "HP\n\(HP_mage)"
                    }
                }else if characterNode.name == "僧侶" {
                    HP_priest -= ATK_damage
                    death = HP_priest
                    if HP_priest <= 0 {
                        priestHPLabel?.text = "HP\n0"
                    }else{
                        priestHPLabel?.text = "HP\n\(HP_priest)"
                    }
                }
                
                print("\(String(describing: characterNode.name))HP = \(death)")
                
                if death <= 0 {
                    characterNode.removeFromParent()
                }
                
                death = 1
            }
            
            //キャラクターが敵に触れた時
            if partnerNode.name == "敵" {
                
                if characterNode.name == "戦士" {
                    HP_enemy -= ATK_warrior
                    death = HP_enemy
                }else if characterNode.name == "剣士" {
                    HP_enemy -= ATK_knight
                    death = HP_enemy
                }else if characterNode.name == "魔法使い" {
                    HP_enemy -= ATK_mage
                    death = HP_enemy
                }else if characterNode.name == "僧侶" {
                    HP_enemy -= ATK_priest
                    death = HP_enemy
                }
                
                enemyHPLabel?.text = "HP:\(HP_enemy)"
                print("残りHP＝\(HP_enemy)")
                if HP_enemy <= 0 {
                    partnerNode.removeFromParent()
                    enemyHPLabel?.text = "🎉Congratulations🎉"
                }
            }
            
        }
    }
    
    //ノードが接触後離れた時に呼び出されるメソッド
    func didEnd(_ contact: SKPhysicsContact) {
        print("離れた！ = \(String(describing: contact.bodyA.node?.name)) : \(String(describing: contact.bodyB.node?.name))")
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        var characterNode: SKNode
        var partnerNode: SKNode
        
        //接触後に接触したどちらか、もしくは両方のノードが存在しなかった場合didendContactを抜ける
        if nodeA == nil || nodeB == nil {
            return
        }
        //キャラクターが他のノードと衝突した場合の処理
        if nodeA?.physicsBody?.categoryBitMask == CategoryBitMask.character || nodeB?.physicsBody?.categoryBitMask == CategoryBitMask.character {
            //キャラクター側と衝突先側それぞれに名前をつける
            if nodeA?.physicsBody?.categoryBitMask == CategoryBitMask.character {
                characterNode = nodeA!
                partnerNode = nodeB!
            }else{
                characterNode = nodeB!
                partnerNode = nodeA!
            }
            
            //キャラクターがゲートから離れた時
            if partnerNode.name == "ゲート" {
                if characterNode.position.y < (partnerNode.position.y - sizeDefault_Caracter.height / 2) {
                    //キャラクターがゲートより下に離れた場合（ゲートを通過しなかった）
                    return
                }else{
                    //キャラクターがゲートを通過した場合ゲートと衝突するようにする
                    print("通過した！\(String(describing: characterNode.name))")
                    characterNode.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floorBottom | CategoryBitMask.cue | CategoryBitMask.gate | CategoryBitMask.damage
                    characterNode.physicsBody?.fieldBitMask = 0
                }
            }
            
        }
    }
    
    //画面タッチ時の呼び出しメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            originalPosition = touchLocation
            
            if nowPlace == "ステージ" {
                firstCuePosition = cue.position
            }
        }
        
        if nowPlace == "ステージ" {
        //キューを一度isDynamic = false にして引っ張りやすくする
            if cue.physicsBody?.isDynamic == true {
                cue.physicsBody?.isDynamic = false
            }
        }
        
        if nowPlace == "OP画面" {
            removeAllChildren()
            stageSelect()
        }
    }
    
    //画面タッチ移動時の呼び出しメソッド
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nowPlace == "OP画面" {
            
        }
        
        if nowPlace == "ステージセレクト" {
            
        }
        
        if nowPlace == "ステージ" {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let node = self.childNode(withName: "キュー") // 移動させたいノードの参照
                let deltaY = originalPosition.y - touchLocation.y
                
                //キューをした方向にのみ引っ張れるようにする＆最大引っ張り距離はキューの長さの半分
                if deltaY > 0 && deltaY < cue.size.height / 2{
                    node?.position.y = firstCuePosition.y - deltaY
                }else{
                    print("限界！")
                }
            }
            
        }
    }

    //画面から手を離した時の呼び出しメソッド
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touches セットから最初のタッチオブジェクトを取得
        if let touch = touches.first {
            // タッチの位置を取得
            let touchLocation = touch.location(in: self)

            if touchLocation.x < stageSize.width / 5 && touchLocation.y > stageSize.height * 0.9 {
                reset()
            }
            
            if touchLocation.x > (stageSize.width - stageSize.width / 5 ) && touchLocation.y > stageSize.height * 0.9 {
                print(debug)
                if debug == 0 {
                    pinLattice()
                }else{
                    // シーン内のすべての子ノードを取得
                    let allNodes = self.children

                    // 特定の名前を持つノードをフィルタリングして取得
                    let dotNodes = allNodes.filter { $0.name == "デバッグノード" }

                    // 取得したノードを削除
                    dotNodes.forEach { $0.removeFromParent() }

                    debug = 0

                    
                }
            }
            
            
        }
        originalPosition = nil
        
        if nowPlace == "ステージ" {
            cue.physicsBody?.isDynamic = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func reset() {
        removeAllChildren()
        self.didMove(to: self.view!)
    }
    
    @objc func stage1Tapped(sender : UIButton) {
        removeAllChildren()
        // ボタンを一括で削除する
        for button in view!.subviews {
            if let button = button as? UIButton {
                button.removeFromSuperview()
            }
        }

        stage1_1()
        nowPlace = "ステージ"
    }
    @objc func stage2Tapped(sender : UIButton) {
        removeAllChildren()
        // ボタンを一括で削除する
        for button in view!.subviews {
            if let button = button as? UIButton {
                button.removeFromSuperview()
            }
        }

        stage1_1()
        nowPlace = "ステージ"
    }
    @objc func stage3Tapped(sender : UIButton) {
        removeAllChildren()
        // ボタンを一括で削除する
        for button in view!.subviews {
            if let button = button as? UIButton {
                button.removeFromSuperview()
            }
        }

        stage1_1()
        nowPlace = "ステージ"
    }
}
