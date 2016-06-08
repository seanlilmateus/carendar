module Carendar
  class PreferencesViewController < BaseViewController

    def viewDidLoad
      super
      b1, b2 = create_boxes
      token_field = create_token_field
      @full_token_delegate ||= FullTokenDelegate.new WeakRef.new(token_field)
      token_field.delegate = @full_token_delegate
      [ b1, b2, token_field, restart_switcher, restart_label ].each do |sbv|
        self.view.addSubview(sbv)
      end
      
      @tokenizer = Carendar::Token::Provider.instance
    end


    def viewWillAppear
      super
      box1, box2 = self.view.subviews.select { |sb| sb.is_a?(NSBox) }
      time_elements = create_token_elements(box1, @tokenizer.time_token)
      date_elements = create_token_elements(box2, @tokenizer.date_token)
      positioning(time_elements)
      positioning(date_elements)
    end


    def viewDidAppear
      super
      token_field = self.view.subviews.find { |s| s.is_a?(NSTokenField) }
      controller = NSUserDefaultsController.sharedUserDefaultsController
      initial = { CURRENT_FORMAT => Token::Provider.defaults }
      controller.setInitialValues(initial)
      options = {
        NSValueTransformerNameBindingOption => "FormatTransformer",
        NSContinuouslyUpdatesValueBindingOption => true,
        NSValidatesImmediatelyBindingOption => true,
      }
      token_field.bind( NSValueBinding, 
              toObject: controller, 
           withKeyPath: "values.current_format", 
               options: options)
      token_field.window.makeFirstResponder(token_field.superview)
    end


    def viewWillDisappear
      super
      token_field = self.view.subviews.find { |s| s.is_a?(NSTokenField) }
      token_field.window.makeFirstResponder(token_field.superview)
      token_field.unbind(NSValueBinding)
    end


    def preferredContentSize
      NSSize.new(500, 470)
    end


    def update_view_constraints
      box1, box2 = self.view.subviews.select { |sb| sb.is_a?(NSBox) }
      toke_field = self.view.subviews.find { |sb| sb.is_a?(NSTokenField) }
      
      NSLayoutConstraint.activateConstraints([
        toke_field.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, constant:- 40),
        toke_field.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
        toke_field.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant:15),
      
        box1.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, constant:-40),
        box1.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),        
        box1.topAnchor.constraintEqualToAnchor(toke_field.bottomAnchor, constant:20),
        box1.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor, multiplier:0.30),
        
        box2.widthAnchor.constraintEqualToAnchor(box1.widthAnchor),
        box2.centerXAnchor.constraintEqualToAnchor(box1.centerXAnchor),
        box2.widthAnchor.constraintEqualToAnchor(box2.widthAnchor),
        box2.topAnchor.constraintEqualToAnchor(box1.bottomAnchor, constant:20),
        box2.heightAnchor.constraintEqualToAnchor(box1.heightAnchor),
        
        restart_switcher.widthAnchor.constraintEqualToConstant(100),
        restart_switcher.heightAnchor.constraintEqualToConstant(20),
        restart_switcher.topAnchor.constraintEqualToAnchor(box2.bottomAnchor, constant:12),
        restart_switcher.leftAnchor.constraintEqualToAnchor(box2.leftAnchor),
        restart_label.topAnchor.constraintEqualToAnchor(box2.bottomAnchor, constant:12),
        
        restart_label.leftAnchor.constraintEqualToAnchor(restart_switcher.rightAnchor, constant:12),
      ])
    end


    private
    def restart_switcher
      @__restart_switch__ ||= SwitchControl.new.tap do |sw|
        sw.translatesAutoresizingMaskIntoConstraints = false
        @auto_starter = AutoStarter.new(sw)
      end
    end


    def restart_label
      @restart_label ||= begin
        str = localized_string("Launch %@ at Login")
        label_title = NSString.stringWithFormat(str, AppInfo.name)
        Label.create(label_title)
      end
    end


    def simple_delegate
      @simple_delegate ||= SimpleTokenDelegate.new
    end


    def create_token_elements(destination, items)
      items.map do |tok|
        token = create_token_field do |tk|
          tk.delegate = simple_delegate
          tk.objectValue = [tok]
          tk.bordered, tk.editable, tk.selectable = false, false, true
          tk.backgroundColor = NSColor.clearColor
        end
        label = Label.create("#{localized_string(token.objectValue.first.name)}:")
        destination.addSubview(label)
        destination.addSubview(token)
        [label, token]
      end
    end


    def positioning(items)
      lhs_items, rhs_items = items.partition.with_index { |_, i| i.even? }
      label0, token0 = lhs_items[0]
      label1, token1 = rhs_items[0]
      
      NSLayoutConstraint.activateConstraints([
        label0.widthAnchor.constraintEqualToAnchor(label0.superview.widthAnchor, multiplier: 1.0/4.0),
        label0.topAnchor.constraintEqualToAnchor(label0.superview.topAnchor, constant:10),
        label0.leftAnchor.constraintEqualToAnchor(label0.superview.leftAnchor, constant:12),
        
        token0.topAnchor.constraintEqualToAnchor(label0.topAnchor),
        token0.widthAnchor.constraintEqualToAnchor(label0.widthAnchor),
        token0.leftAnchor.constraintEqualToAnchor(label0.rightAnchor, constant:10),
        
        
        label1.widthAnchor.constraintEqualToAnchor(label1.superview.widthAnchor, multiplier:1.0/4.0),
        label1.topAnchor.constraintEqualToAnchor(label1.superview.topAnchor, constant:10),
        label1.leftAnchor.constraintEqualToAnchor(label1.superview.centerXAnchor, constant:12),
        
        token1.topAnchor.constraintEqualToAnchor(label1.topAnchor),
        token1.widthAnchor.constraintEqualToAnchor(label1.widthAnchor),
        token1.leftAnchor.constraintEqualToAnchor(label1.rightAnchor, constant:10),
      ])
      
      action = Proc.new do |(la, ta), (lb, tb)|
        [ 
          lb.leftAnchor.constraintEqualToAnchor(la.leftAnchor),
          tb.topAnchor.constraintEqualToAnchor(ta.bottomAnchor, constant:12),
          
          tb.leftAnchor.constraintEqualToAnchor(ta.leftAnchor),
          lb.topAnchor.constraintEqualToAnchor(la.bottomAnchor, constant:12),
        ]
      end
      NSLayoutConstraint.activateConstraints lhs_items.each_cons(2).flat_map(&action)
      NSLayoutConstraint.activateConstraints rhs_items.each_cons(2).flat_map(&action)
    end


    def create_boxes
      ["Date Components", "Time Components"].map do |name|
        NSBox.new.tap do |b|
          b.translatesAutoresizingMaskIntoConstraints = false
          b.title = localized_string(name)
        end
      end
    end


    def create_token_field
      TokenField.alloc.init.tap do |tf|
        tf.translatesAutoresizingMaskIntoConstraints = false
        yield(tf) if block_given?
        tf
      end
    end

  end
end
