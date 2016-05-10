module Carendar
  class PreferencesViewController < BaseViewController
    def viewDidLoad
      super
      b1, b2 = create_boxes
      token_field = create_token_field
      @full_token_delegate ||= FullTokenDelegate.new WeakRef.new(token_field)
      token_field.delegate = @full_token_delegate
      self.view.addSubview(b1)
      self.view.addSubview(b2)
      self.view.addSubview(token_field)
      self.view.addSubview(restart_switcher)
      self.view.addSubview(restart_label)
      
      @tokenizer = Carendar::Token::Provider.instance
      @settings = SettingsModel.instance
      options = { 
        NSContinuouslyUpdatesValueBindingOption => true,
        NSValidatesImmediatelyBindingOption => true,
      }
      token_field.bind( NSValueBinding, 
              toObject: @settings, withKeyPath: "current_format", options: options)
    end
    
    def viewWillAppear
      super
      box1, box2 = self.view.subviews.select { |sb| sb.is_a?(NSBox) }
      date_elements = create_token_elements(box1, @tokenizer.date_token)
      time_elements = create_token_elements(box2, @tokenizer.time_token)
      positioning(date_elements)
      positioning(time_elements)
    end
    
    def update_view_constraints
      self.view.extend(Layout::View)
      box1, box2 = self.view.subviews.select { |sb| sb.is_a?(NSBox) }
      toke_field = self.view.subviews.find { |sb| sb.is_a?(NSTokenField) }
      self.view.addConstraints([
        toke_field.width == self.view.width - 40,
        toke_field.centerX == self.view.centerX,
        toke_field.top == self.view.top + 15,
        
        box1.width == self.view.width - 40,
        box1.centerX == self.view.centerX,
        box1.top == toke_field.bottom + 20,
        box1.height == self.view.height * 0.30,
        
        box2.centerX == self.view.centerX,
        box2.width == self.view.width - 40,
        box2.top == box1.bottom + 20,
        box2.width == self.view.width - 40,
        box2.height == self.view.height * 0.30,
        restart_switcher.width == 100,
        restart_switcher.height == 20,
        restart_switcher.top == box2.bottom + 12,
        restart_switcher.left == box2.left,
        restart_label.top == box2.bottom + 12,
        restart_label.left == restart_switcher.right + 12,
      ])
    end
    
    private
    def restart_switcher
      @__restart_switch__ ||= SwitchControl.new.tap do |sw|
        sw.translatesAutoresizingMaskIntoConstraints = false
        @auto_starter = AutoStarter.new(sw)
        sw.extend(Layout::View)
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
          tk.extend(Layout::View)
        end
        label = Label.create("#{localized_string(token.objectValue.first.name)}:")
        destination.addSubview(label)
        destination.addSubview(token)
        label.superview.extend(Layout::View)
        [label, token]
      end
    end
    
    def positioning(items)
      lhs_items, rhs_items = items.partition.with_index { |_, i| i.even? }
      label0, token0 = lhs_items[0]
      label1, token1 = rhs_items[0]
      self.view.addConstraints [
        label0.width == (label0.superview.width / 4.0),
        label0.top   == label0.superview.top + 10,
        label0.left  == label0.superview.left + 12,
        token0.top   == label0.top,
        token0.width == label0.width,
        token0.left  == label0.right + 10,
        
        label1.width == (label1.superview.width / 4.0),
        label1.top   == label1.superview.top + 10,
        label1.left  == label1.superview.centerX + 12,
        token1.top   == label1.top,
        token1.width == label1.width,
        token1.left  == label1.right + 10,
      ]
      
      action = Proc.new do |(la, ta), (lb, tb)|
        [ lb.left  == la.left,
          tb.top   == ta.bottom + 12, 
          tb.left  == ta.left, 
          lb.top   == la.bottom + 12,]
      end
      self.view.addConstraints lhs_items.each_cons(2).flat_map(&action)
      self.view.addConstraints rhs_items.each_cons(2).flat_map(&action)
    end
    
    def create_boxes
      ["Date Components", "Time Components"].map do |name|
        NSBox.new.tap do |b|
          b.translatesAutoresizingMaskIntoConstraints = false
          b.title = localized_string(name)
          b.extend(Layout::View)
        end
      end
    end
    
    def create_token_field
      TokenField.alloc.init.tap do |tf|
        tf.extend(Layout::View)
        tf.translatesAutoresizingMaskIntoConstraints = false
        yield(tf) if block_given?
        tf
      end
    end
  end
end