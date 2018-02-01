//
//  GameScene.swift
//  FlappyBird
//
//  Created by 山口航輝 on 2018/01/24.
//  Copyright © 2018年 koki.yamaguchi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene ,SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!

    var wallNode:SKNode!
    
    var itemNode:SKNode!
    
    var bird:SKSpriteNode!    // 追加

    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4
    
    // スコア
    var score = 0
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    let userDefaults:UserDefaults = UserDefaults.standard // 追加
    
    //Item用スコア
    var score2=0
    var scoreLabelNodeItem:SKLabelNode!
    

    
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        physicsWorld.contactDelegate = self // ←追加

        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)    // ←追加

        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加
        
        //Item用のノード
        itemNode=SKNode()
        scrollNode.addChild(itemNode)
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()   // 追加

        setupScoreLabel()
        setupItem()
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNodeItem = SKLabelNode()
        scoreLabelNodeItem.fontColor = UIColor.black
        scoreLabelNodeItem.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        scoreLabelNodeItem.zPosition = 100 // 一番手前に表示する
        scoreLabelNodeItem.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNodeItem.text = "Score(Item):\(score2)"
        self.addChild(scoreLabelNodeItem)
        
        score2 = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupItem(){
        let itemTexture=SKTexture(imageNamed: "wing")
        itemTexture.filteringMode = .linear
        
        //移動するサイズ
        let movingItemDistance = CGFloat(self.frame.size.width + itemTexture.size().width*5)
        
        print("moving:\(movingItemDistance)")
        
        // 画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingItemDistance, y: 0, duration:TimeInterval((self.frame.size.width - 10 + itemTexture.size().width*4)*4/self.frame.size.width))
        
        print("moveItem:\((self.frame.size.width + itemTexture.size().width*5)*4/self.frame.size.width)")
        
        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let ItemAnimation = SKAction.sequence([moveItem, removeItem])
        
        //アイテムを生成するアクション
        let createItemAnimation=SKAction.run {
            
            //ノード作成
            let Item = SKNode()
            Item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width*4, y: 50.0)
            
            print("Itemposition:\(Item.position)")
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // 下の壁のY軸の下限
            let Item_lowest_y = UInt32( center_y - itemTexture.size().height / 2 -  random_y_range / 2)
            
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let Item_y = CGFloat(Item_lowest_y + random_y)
            
            // Itemを作成
            let itemAppear = SKSpriteNode(texture: itemTexture)
            itemAppear.position = CGPoint(x: 0, y: Item_y)
            Item.addChild(itemAppear)
            
            
            // スプライトに物理演算を設定する
            // スプライトに物理演算を設定する
            itemAppear.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())    // ←追加
            itemAppear.physicsBody?.categoryBitMask = self.itemCategory
            itemAppear.physicsBody?.contactTestBitMask = self.birdCategory
            itemAppear.physicsBody?.affectedByGravity = false
            itemAppear.physicsBody?.isDynamic=false
            itemAppear.run(ItemAnimation)
            self.itemNode.addChild(Item)
            
           
            
            // --- ここまで追加 ---
            
            Item.run(ItemAnimation)
            
           
        }
        
        //待ち時間のアクション
        let waitAnimationItem = SKAction.wait(forDuration: 4)
        
        // Itemを作成->待ち時間->Itemを作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimationItem = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimationItem]))
        
        itemNode.run(repeatForeverAnimationItem)
        
        
    }
    
    
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),
                y: groundTexture.size().height * 0.5
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false // ←追加
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
        
    }
        
        func setupCloud() {
            // 雲の画像を読み込む
            let cloudTexture = SKTexture(imageNamed: "cloud")
            cloudTexture.filteringMode = .nearest
            
            // 必要な枚数を計算
            let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
            
            // スクロールするアクションを作成
            // 左方向に画像一枚分スクロールさせるアクション
            let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
            
            // 元の位置に戻すアクション
            let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
            
            // 左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
            let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
            
            // スプライトを配置する
            for i in 0..<needCloudNumber {
                let sprite = SKSpriteNode(texture: cloudTexture)
                sprite.zPosition = -100 // 一番後ろになるようにする
                
                // スプライトの表示する位置を指定する
                sprite.position = CGPoint(
                    x: cloudTexture.size().width * (CGFloat(i) + 0.5),
                    y: self.size.height - cloudTexture.size().height * 0.5
                )
                
                // スプライトにアニメーションを設定する
                sprite.run(repeatScrollCloud)
                
                // スプライトを追加する
                scrollNode.addChild(sprite)
            }
        }
        
        func setupWall() {
            // 壁の画像を読み込む
            let wallTexture = SKTexture(imageNamed: "wall")
            wallTexture.filteringMode = .linear
            
            // 移動する距離を計算
            let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
            
           
            // 画面外まで移動するアクションを作成
            let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
            
            // 自身を取り除くアクションを作成
            let removeWall = SKAction.removeFromParent()
            
            // 2つのアニメーションを順に実行するアクションを作成
            let wallAnimation = SKAction.sequence([moveWall, removeWall])
            
            // 壁を生成するアクションを作成
            let createWallAnimation = SKAction.run({
                // 壁関連のノードを乗せるノードを作成
                let wall = SKNode()
                wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
                
               
                wall.zPosition = -50.0 // 雲より手前、地面より奥
                
                // 画面のY軸の中央値
                let center_y = self.frame.size.height / 2
                // 壁のY座標を上下ランダムにさせるときの最大値
                let random_y_range = self.frame.size.height / 4
                // 下の壁のY軸の下限
                let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
                // 1〜random_y_rangeまでのランダムな整数を生成
                let random_y = arc4random_uniform( UInt32(random_y_range) )
                // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
                let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
                
                // キャラが通り抜ける隙間の長さ
                let slit_length = self.frame.size.height / 6
                
                // 下側の壁を作成
                let under = SKSpriteNode(texture: wallTexture)
                under.position = CGPoint(x: 0.0, y: under_wall_y)
                wall.addChild(under)
                
                // スプライトに物理演算を設定する
                under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加

                // 衝突の時に動かないように設定する
                under.physicsBody?.isDynamic = false    // ←追加
                
                // 上側の壁を作成
                let upper = SKSpriteNode(texture: wallTexture)
                upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
                
                // スプライトに物理演算を設定する
                upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                upper.physicsBody?.categoryBitMask = self.wallCategory    // ←追加

                
                // 衝突の時に動かないように設定する
                upper.physicsBody?.isDynamic = false    // ←追加

                
                wall.addChild(upper)
                
                // スコアアップ用のノード --- ここから ---
                let scoreNode = SKNode()
                scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
                scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                scoreNode.physicsBody?.isDynamic = false
                scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
                
                wall.addChild(scoreNode)
                // --- ここまで追加 ---

                
                
                wall.run(wallAnimation)
                
                self.wallNode.addChild(wall)
            })
            
            // 次の壁作成までの待ち時間のアクションを作成
            let waitAnimation = SKAction.wait(forDuration: 2)
            
            // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
            
            wallNode.run(repeatForeverAnimation)
        }
    
    // 以下追加
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // アニメーションを設定
        bird.run(flap)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)    // ←追加

        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加

        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory // ←追加

        
        
        // スプライトを追加する
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 { // 追加
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の力を与える
           bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 { // --- ここから ---
            restart()
        } // --- ここまで追加 ---
    }

    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        
        let sound:SKAction = SKAction.playSoundFileNamed("jump01.mp3", waitForCompletion: true)
        
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"    // ←追加

            // ベストスコア更新か確認する --- ここから ---
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加

                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            } // --- ここまで追加---
            
           
            
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            print("接触")
            contact.bodyA.node?.removeFromParent()
           score2 += 1
            scoreLabelNodeItem.text = "Score(Item):\(score2)"
            self.run(sound)
            
        }
        
        
        
        
        else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")    // ←追加
        
        score2 = 0
        scoreLabelNodeItem.text = "Score(Item):\(score2)"

        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    
    }


