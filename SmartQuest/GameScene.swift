//
//  GameScene.swift
//  SmartQuest
//
//  Created by セロラー on 2023/06/19.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var enemyHPLabel: SKLabelNode? = nil
    
    //各種数値格納庫
    var topSize = CGSize(width: 0, height: 0)       //天井のサイズ
    var wallSize = CGSize(width: 0, height: 0)      //壁のサイズ
    var floorSize = CGSize(width: 0, height: 0)     //床のサイズ
    var cueSize = CGSize(width: 0, height: 0)       //キューのサイズ
    var notchHeight: CGFloat = 0.0                  //ノッチ部分の高さを格納する変数
    
    //発射地点のノード
    var launchNode: SKFieldNode!
    
    //各種パラメーター格納用変数
    
    var enemyHP: UInt32 = 10
    
    var sizeDefault_Caracter = CGSize(width: 0, height: 0)  //キャラクターの基本サイズ
    var frictionDefault_Caracter = 0.1                      //摩擦係数
    var birthPosition = CGPoint(x: 0, y: 0)                 //最初のキャラが生成される座標
    
    let restitution_Wall: CGFloat = 0.3                    //壁の反発係数
    let restitution_Caracter: CGFloat = 0.5                 //キャラクターの反発係数
    let restitution_cue: CGFloat = 0.0                      //キューの反発係数
    let restitution_pin: CGFloat = 0.7                      //ピンの反発係数
    let restitution_gate: CGFloat = 0.5                     //ゲートの反発係数
    let restitution_enemy: CGFloat = 1.5
    
    let friction_cue: CGFloat = 1.0                         //キューの摩擦係数
    let friction_pin: CGFloat = 0.0                         //ピンの摩擦係数
    let friction_wall: CGFloat = 0.7
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
    let gravityStrength:Float = 9.8 / 4   //重力の強さ
    
    
    
    var cue: SKSpriteNode!
    var originalPosition: CGPoint! //タップされた座標
    var firstCuePosition: CGPoint! //タップされた時のキューの座標
    
    //ピンテクスチャの生成
    let pinTexture = SKTexture(imageNamed: "pin")
    
    

    
    
    
    override func didMove(to view: SKView) {
        //ノッチ部分のサイズを取得する
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let statusBarManager = windowScene.statusBarManager {
                let statusBarFrame = statusBarManager.statusBarFrame
                notchHeight = statusBarFrame.size.height
            }
        }
        
        //発射地点に重力を発生させるノード
        launchNode = SKFieldNode.linearGravityField(withVector: vector_float3(x: 1, y: 0, z: 0))
        launchNode.strength = gravityStrength / 2
        launchNode.position = CGPoint(x: self.size.width - sizeDefault_Caracter.width / 2, y: sizeDefault_Caracter.height / 2)
        launchNode.physicsBody?.categoryBitMask = CategoryBitMask.launch
        addChild(launchNode)
        
        //各キャラの共通設定
        sizeDefault_Caracter = CGSize(width: self.size.width / 15, height: self.size.width / 15)   //サイズ
        birthPosition = CGPoint(x: sizeDefault_Caracter.width * 1.1, y: SKTexture(imageNamed: "floor").size().height / 2)

        //背景を黄緑一色にする
        let yellowGreenColor = UIColor(red: 0.68, green: 0.89, blue: 0.38, alpha: 1.0)
        self.backgroundColor = yellowGreenColor
        
        physicsWorld.gravity = CGVector(dx: 0, dy: Int(-gravityStrength))
        //SKPhysicsContactDelegateを有効にしてノード同士が衝突した際にcontactメソッドが呼び出されるようにする
        physicsWorld.contactDelegate = self
        
        
        setWall()
        makeCharacter()
        setPin()
        setEnemy()
        setDamage()
        
        
    }
    
    //各種壁の配置
    func setWall() {
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
        
        wallRight.size = CGSize(width: wallRight.size.width, height: self.size.height * 1.1)
        wallRight.physicsBody = SKPhysicsBody(rectangleOf: wallRight.size)
        wallRight.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallRight.physicsBody?.restitution = restitution_Wall
        wallRight.physicsBody?.friction = friction_wall
        wallRight.position = CGPoint(x: self.size.width, y: self.size.height / 2)
        wallRight.physicsBody?.isDynamic = false
        
        wallSize = wallRight.size   //壁のサイズを登録
        
        wallLeft.size = CGSize(width: wallLeft.size.width, height: self.size.height * 1.1)
        wallLeft.physicsBody = SKPhysicsBody(rectangleOf: wallLeft.size)
        wallLeft.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallLeft.physicsBody?.restitution = restitution_Wall
        wallLeft.physicsBody?.friction = friction_wall
        wallLeft.position = CGPoint(x: 0, y: self.size.height / 2)
        wallLeft.physicsBody?.isDynamic = false
        
        top.size = CGSize(width: self.size.width, height: top.size.height * self.size.width / top.size.width)
        top.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "top"), size: CGSize(width: top.size.width, height: top.size.height))
        top.physicsBody?.categoryBitMask = CategoryBitMask.wall
        top.physicsBody?.isDynamic = false
        top.physicsBody?.friction = 0
        top.physicsBody?.restitution = restitution_Wall
        top.physicsBody?.friction = friction_wall
        top.position = CGPoint(x: self.size.width / 2, y: self.size.height - top.size.height / 2 - notchHeight)
        
        topSize = top.size  //天井のサイズを登録
        
        //画面一番下の床
        floorBottom.size = CGSize(width: floorTexture.size().width, height: floorTexture.size().height)
        floorBottom.physicsBody = SKPhysicsBody(rectangleOf: floorBottom.size)
        floorBottom.physicsBody?.categoryBitMask = CategoryBitMask.floorBottom
        floorBottom.physicsBody?.contactTestBitMask = CategoryBitMask.character
        floorBottom.physicsBody?.isDynamic = false
        floorBottom.physicsBody?.restitution = restitution_Wall
        floorBottom.physicsBody?.friction = friction_wall
        floorBottom.position = CGPoint(x: floorBottom.size.width / 2, y: 0)
        floorBottom.name = "床"
        
        floorSize = floorBottom.size    //床のサイズを登録
        
        wallLail.size = CGSize(width: wallLail.size.width / 2, height: self.size.height - (top.size.height + notchHeight + sizeDefault_Caracter.height * 1.01))
        wallLail.physicsBody = SKPhysicsBody(rectangleOf: wallLail.size)
        wallLail.physicsBody?.categoryBitMask = CategoryBitMask.wall
        wallLail.physicsBody?.restitution = restitution_Wall
        //発射レール壁の位置は下と右にボールの通り道ができるように配置
        wallLail.position = CGPoint(x: self.size.width - sizeDefault_Caracter.width * 1.2 - wallRight.size.width / 2, y: wallLail.size.height / 2 + sizeDefault_Caracter.height * 1.1 + floorBottom.size.height / 2)
        wallLail.physicsBody?.isDynamic = false
        
        //ステージ下の落下判定床
        floor.size = CGSize(width: self.size.width, height: floor.size.height / 5)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = CategoryBitMask.floor
        floor.physicsBody?.isDynamic = false
        floor.position = CGPoint(x: self.size.width / 2 - (self.size.width - wallLail.position.x), y: wallLail.position.y - wallLail.size.height / 2 + floor.size.height / 2)
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
        cue = SKSpriteNode(texture: cueTexture, size: CGSize(width: sizeDefault_Caracter.width * 0.8, height: self.size.height / 2))
        
        cue.physicsBody = SKPhysicsBody(texture: cueTexture, size: cue.size)
        cue.physicsBody?.isDynamic = true
        cue.physicsBody?.affectedByGravity = false  //重力の影響を受けなくする
        cue.physicsBody?.fieldBitMask = 0
        cue.physicsBody?.friction = friction_cue    //摩擦係数
        cue.physicsBody?.restitution = restitution_cue //反発係数
        cue.physicsBody?.allowsRotation = false
        cue.physicsBody?.categoryBitMask = CategoryBitMask.wall
        cue.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall
        cue.position = CGPoint(x: self.size.width - wallRight.size.width / 2 - sizeDefault_Caracter.width / 2, y: -cue.size.height / 3)
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
        
        //各ピンの座標リスト上からpin1,pin2...
        let pinPositions: [CGPoint] = [
            CGPoint(x: sizeDefault_Caracter.width / 2 + wallSize.width / 2, y: self.size.height - notchHeight - topSize.height),
            CGPoint(x: wallSize.width * 1.1 , y: self.size.height - notchHeight - topSize.height + sizeDefault_Caracter.height / 2),
            CGPoint(x: self.size.width * Double.random(in: 0.25..<0.75), y: self.size.height * Double.random(in: 0.3..<0.8)),
            CGPoint(x: self.size.width * Double.random(in: 0.25..<0.75), y: self.size.height * Double.random(in: 0.3..<0.8)),
            CGPoint(x: self.size.width * Double.random(in: 0.25..<0.75), y: self.size.height * Double.random(in: 0.3..<0.8))
        ]
        
        let pinCount = 5    //生成するピンの個数
        
        //ピンを生成
        for i in 0..<pinCount {
            let pin = SKSpriteNode(texture: pinTexture, size: CGSize(width: sizeDefault_Caracter.width / 5, height: sizeDefault_Caracter.height / 5))
            pin.physicsBody = SKPhysicsBody(circleOfRadius: pin.size.width / 2)
            pin.physicsBody?.isDynamic = false
            pin.physicsBody?.restitution = restitution_pin  //反発係数
            pin.physicsBody?.friction = friction_pin        //摩擦係数
            pin.name = "Pin\(i+1)" // ピンに番号を振る
            pin.position = pinPositions[i]
            
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
        warrior.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue
        warrior.position = birthPosition
        warrior.name = "戦士"
        
        //剣士
        knight.size = sizeDefault_Caracter
        knight.physicsBody = SKPhysicsBody(circleOfRadius: knight.size.width / 2.0)
        knight.physicsBody?.isDynamic = true
        knight.physicsBody?.friction = frictionDefault_Caracter
        knight.physicsBody?.fieldBitMask = 0
        knight.physicsBody?.categoryBitMask = CategoryBitMask.character
        knight.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        knight.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue
        knight.position = CGPoint(x: birthPosition.x + warrior.size.width, y: birthPosition.y)
        knight.name = "剣士"
        
        //僧侶
        priest.size = sizeDefault_Caracter
        priest.physicsBody = SKPhysicsBody(circleOfRadius: priest.size.width / 2.0)
        priest.physicsBody?.isDynamic = true
        priest.physicsBody?.friction = frictionDefault_Caracter
        priest.physicsBody?.fieldBitMask = 0
        priest.physicsBody?.categoryBitMask = CategoryBitMask.character
        priest.physicsBody?.contactTestBitMask = CategoryBitMask.floor
        priest.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floor | CategoryBitMask.floorBottom | CategoryBitMask.cue
        priest.position = CGPoint(x: birthPosition.x + warrior.size.width * 2, y: birthPosition.y)
        priest.name = "僧侶"
        
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
        enemy.position = CGPoint(x: self.size.width / 2, y: self.size.height / 4)
        enemy.name = "敵"
        
        enemyHP = 10
        enemyHPLabel = SKLabelNode(text: "HP:\(enemyHP)")
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
            CGSize(width: wallSize.width / 5, height: self.size.height / 10),
            CGSize(width: wallSize.width / 5, height: self.size.height / 10),
            CGSize(width: wallSize.width, height: wallSize.width),
            CGSize(width: wallSize.width, height: wallSize.width),
            CGSize(width: wallSize.width, height: wallSize.width)
        ]
        
        //各ダメージ判定の座標リスト
        let damagePositions: [CGPoint] = [
            CGPoint(x: wallSize.width / 2, y: self.size.height  /   2),
            CGPoint(x: self.size.width - wallSize.width - sizeDefault_Caracter.width * 1.1, y: self.size.height / 2),
            CGPoint(x: self.size.width * Double.random(in: 0.2..<0.6), y: self.size.height * Double.random(in: 0.4..<0.6)),
            CGPoint(x: self.size.width * Double.random(in: 0.2..<0.6), y: self.size.height * Double.random(in: 0.4..<0.6)),
            CGPoint(x: self.size.width * Double.random(in: 0.2..<0.6), y: self.size.height * Double.random(in: 0.4..<0.6))
        ]
        
        
        let damageCount = 5    //生成するピンの個数
        //ダメージ判定を生成
        for i in 0..<damageCount {
            let damage = SKSpriteNode(texture: damageTexture)
            damage.size = damageSizes[i]
            damage.physicsBody = SKPhysicsBody(rectangleOf: damage.size)
            damage.physicsBody?.isDynamic = false
            damage.physicsBody?.categoryBitMask = CategoryBitMask.damage
            damage.physicsBody?.collisionBitMask = 0
            damage.physicsBody?.contactTestBitMask = CategoryBitMask.character
            damage.physicsBody?.restitution = restitution_Wall  //反発係数
            damage.physicsBody?.friction = friction_wall        //摩擦係数
            damage.name = "ダメージ" // ダメージ判定に番号を振る
            damage.position = damagePositions[i]
            
            self.addChild(damage)
        }
        
        
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
                characterNode.removeFromParent()
            }
            
            //キャラクターが敵に触れた時
            if partnerNode.name == "敵" {
                enemyHP -= 1
                enemyHPLabel?.text = "HP:\(enemyHP)"
                print("残りHP＝\(enemyHP)")
                if enemyHP == 0 {
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
                if characterNode.position.y < (partnerNode.position.y - sizeDefault_Caracter.height / 2 ) {
                    //キャラクターがゲートより下に離れた場合（ゲートを通過しなかった）
                    return
                }else{
                    //キャラクターがゲートを通過した場合ゲートと衝突するようにする
                    print("通過した！\(String(describing: characterNode.name))")
                    characterNode.physicsBody?.collisionBitMask = CategoryBitMask.character | CategoryBitMask.wall | CategoryBitMask.floorBottom | CategoryBitMask.cue | CategoryBitMask.gate
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
            firstCuePosition = cue.position
        }
        //キューを一度isDynamic = false にして引っ張りやすくする
        if cue.physicsBody?.isDynamic == true {
            cue.physicsBody?.isDynamic = false
            
        }
        
    }
    
    //画面タッチ移動時の呼び出しメソッド
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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

    //画面から手を離した時の呼び出しメソッド
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touches セットから最初のタッチオブジェクトを取得
        if let touch = touches.first {
            // タッチの位置を取得
            let touchLocation = touch.location(in: self)

            if touchLocation.x < self.size.width / 5 && touchLocation.y > self.size.height * 0.9 {
                reset()
            }
        }
        originalPosition = nil
        cue.physicsBody?.isDynamic = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func reset() {
        removeAllChildren()
        self.didMove(to: self.view!)
    }
}
