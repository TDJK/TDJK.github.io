VUE源码分析
	响应式数据原理
		initMixin ---> 初始化方法( 代码拆分 )
		_init 初始化方法挂载在 vue 原型,传入 options调用
			initProp
			initMethod
			initData
				响应式数据的劫持
					对象 defineReactive使用Object.defineObject进行get / set劫持
						get中每个属性dep实例保存自己的watch
						set中进行派发更新dep.notify()通知相关属性的watch进行更新刷新视图
					数组 重写数组方法/数组内部的对象继续进行劫持
				代理 _data 属性
			initComputed
			initWatch
	模板编译原理
		init $mount挂载[如果有el 属性进行模板渲染]
		[compiler/index.js]compileToFunctions函数
			[compiler/parse.js]生成ast
			优化静态节点
			根据 ast 生成 render 函数
		根据ast 生成代码[compiler/codegen.js]
			static>once>for >if >children>slot
			进行各类检查
			code 字符串生成 render 函数[comiler/toFunction.js]
	初始化渲染原理
		init 组件挂载 
		lifecyce.js  mountComponent(vm,el) --- 将真实的el 赋值给实例的$el属性
		将render 函数转换为 虚拟dom[src/render.js]
		将虚拟 dom 转化成真实 dom [_update]
			分第一次还是之后初次渲染传入的el 就是真实dom ,后面的为上一次的虚拟dom
		_render / _update 原型方法混入
		把定义在原型的方法引入到 Vue 主文件入口 这样所有的实例都能共享方法了
	渲染更新原理
		init
		initState --->initdata 
			通过响应式数据的劫持
			数组 / 对象采用不同的处理方式
	异步更新原理
		创建watcher队列 [watcher.js] 
		实现队列机制  queueWatcher  [ scheduler.js ] 采用 nextTick 进行异步调用
			nextTick 实现原理
				依次判断采用的异步方法
				采用微任务优先的方式调用异步方法去执行nextTick包装的方法
		将$nextTick 挂载到原型 [ render.js ]
	diff算法原理
		patch.js
			初次 oldVnode 是一个真实 dom 直接用新的 dom  替换 el 
			后续更新 diff
				tag 标签不一致直接替换
				tag标签一致 
					先进行属性替换
					对比子元素
				无tag标签 文本节点直接比较内容是否一致
	mixin 原理
		global-api / mixin.js  [ mergeOptions 合并 ]
			util / index.js [ 合并策略 ]
				替换型
					props
					methods
					inject
					computed
					组件 对象 > 组件 mixin 对象 > 组件 mixin -mixin 对象 > ... > 全局 mixin 对象。
				合并型
					data
						当目标 data 对象不包含当前属性时，调用 set 方法进行合并（set方法其实就是一些合并重新赋值的方法）
当目标 data 对象包含当前属性并且当前值为纯对象时，递归合并当前对象值，这样做是为了防止对象存在新增属性
						组件 data > 组件 mixin data > 组件 mixin -mixin data > ... > 全局 mixin
				队列型
					生命周期 / watch
						[
  全局 mixin hook,
  ... ,
  组件mixin-mixin hook,
  组件mixin hook,
  组件 hook
]，
				叠加型
					compoent [最开始初始化全局 API 的时候就设置在 Vue.options 上]
						子主题
					directives [ ~ ] 
					filters [ ~ ]
					Object.create()创建对象,并且实现继承,通过原型链的方式不会相互覆盖,而是权重小的被放到权重大的原型上
						子主题
			优先处理mixins/  遍历父亲合并 ---> 儿子的属性进行合并 [ mergField 函数 ]
			生命周期的调用 全部生命周期各自混入成数组依次执行
		init 初始化  [ initMixin ]
	组件原理
		initGlobalApi [ 初始化全局api ]
			extend
				利用原型继承 根据传入的对象形成子类继承Vue父类返回子类的构造函数,一般作用是通过组件的实例获取组件的构造函数
			组件指令过滤器
				创建component filter directive 方法 同时把他们保存到 options 里面
					组件
						component
						组件的合并策略 [ 使用原型继承的方法, 让儿子继承父亲 并且返回 ]
						组件Vnode生成
						创建组件真实节点
	侦听属性原理
		初始化 state.js
	计算属性原理
		初始化计算属性 state.js
		defineComputed 对计算属性进行劫持
			createComputedGetter
				重写计算属性get方法 根据dirty判断是否需要进行重新计算,并且在重新计算完成后调用watcher ,depend 收集外层渲染watcher 的依赖
		watcher 构造函数改造
			实例化的时候如果是计算属性 不会去调用get 方法访问值进行依赖收集
			update 方法只是把计算 watcher 的 dirty 标识为 true 只有当下次访问到了计算属性的时候才会重新计算
			新增 evaluate 方法用于计算属性重新计算
			新增 depend 方法 用来让计算属性的依赖值收集外层 watcher 依赖
	性能优化
		对象层级不要过深，否则性能就会差
不需要响应式的数据不要放到 data 中（可以用 Object.freeze() 冻结数据）
v-if 和 v-show 区分使用场景
computed 和 watch 区分使用场景
v-for 遍历必须加 key，key 最好是 id 值，且避免同时使用 v-if
大数据列表和表格性能优化-虚拟列表/虚拟表格
防止内部泄漏，组件销毁后把全局变量和事件销毁
图片懒加载
路由懒加载
第三方插件的按需引入
适当采用 keep-alive 缓存组件
防抖、节流运用
服务端渲染 SSR or 预渲染
