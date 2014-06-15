unit DemoForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  JvExComCtrls,
  JvPageListTreeView,
  JvPageList,
  JvExControls,
  Vcl.Buttons,
  JvSwitch,
  SwitchInterface,
  SwitchAbstraction,
  Handler;

type
  TfrmDemo = class(TForm)
    cbbFactorySelect: TComboBox;
    btnCreateCar: TButton;
    lstCarsCreated: TListBox;
    pltvMenu: TJvPageListTreeView;
    plPages: TJvPageList;
    plspAbstractFactory: TJvStandardPage;
    plspAdapter: TJvStandardPage;
    lblAdapterInfo: TLabel;
    edtCustomerId: TEdit;
    lstCustomers: TListBox;
    btnAddCustomer: TSpeedButton;
    plspBridge: TJvStandardPage;
    lstSwitchInfo: TListBox;
    swKitchen: TJvSwitch;
    swBathroom: TJvSwitch;
    lblKitchenSwitch: TLabel;
    lblBathroomSwitch: TLabel;
    plspBuilder: TJvStandardPage;
    btnMeal1: TButton;
    lstMeals: TListBox;
    btnMeal2: TButton;
    plspChainOfResponsibility: TJvStandardPage;
    btnHandleRequests: TButton;
    lstHandlerOutput: TListBox;
    procedure btnCreateCarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddCustomerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure swKitchenOn(Sender: TObject);
    procedure swKitchenOff(Sender: TObject);
    procedure swBathroomOn(Sender: TObject);
    procedure swBathroomOff(Sender: TObject);
    procedure btnMeal1Click(Sender: TObject);
    procedure btnMeal2Click(Sender: TObject);
    procedure btnHandleRequestsClick(Sender: TObject);
  private
    FSwitchAbstraction: TSwitchAbstraction;
    FKitchenSwitch: ISwitch;
    FBathroomSwitch: ISwitch;
    FConcreteHandler1: THandler;
    FConcreteHandler2: THandler;
    FConcreteHandler3: THandler;
  end;

var
  frmDemo: TfrmDemo;

implementation

uses
  AbstractCarFactory,
  Car,
  AdaptedCustomer,
  NewCustomer,
  Switch,
  Director,
  Builder,
  BuilderInterfaces;

{$R *.dfm}

procedure TfrmDemo.FormCreate(Sender: TObject);
begin
  FSwitchAbstraction := TSwitchAbstraction.Create;

  FKitchenSwitch := TKitchenSwitch.Create;
  FBathroomSwitch := TBathroomSwitch.Create;

  FConcreteHandler1 := TConcreteHandler1.Create;
  FConcreteHandler2 := TConcreteHandler2.Create;
  FConcreteHandler3 := TConcreteHandler3.Create;
end;

procedure TfrmDemo.FormDestroy(Sender: TObject);
begin
  FSwitchAbstraction.Free;

  FConcreteHandler3.Free;
  FConcreteHandler2.Free;
  FConcreteHandler1.Free;
end;

{ Builder }

procedure TfrmDemo.btnMeal1Click(Sender: TObject);
var
  director: TDirector;
  mealBuilder1: IBuilder;
  product: IProduct;

begin
  director := TDirector.Create;

  try
    mealBuilder1 := TMealBuilder1.Create;
    director.Construct(mealBuilder1);
    product := mealBuilder1.GetResult;

    lstMeals.Items.Add(product.Display)
  finally
    director.Free;
  end;
end;

procedure TfrmDemo.btnMeal2Click(Sender: TObject);
var
  director: TDirector;
  mealBuilder2: IBuilder;
  product: IProduct;

begin
  director := TDirector.Create;

  try
    mealBuilder2 := TMealBuilder2.Create;
    director.Construct(mealBuilder2);
    product := mealBuilder2.GetResult;

    lstMeals.Items.Add(product.Display)
  finally
    director.Free;
  end;
end;

{ Adapter }

procedure TfrmDemo.btnAddCustomerClick(Sender: TObject);
var
  customerID: Integer;
  customer: TNewCustomer;

begin
  if string(edtCustomerId.Text).IsEmpty then
    Exit;

  customerID := StrToInt(edtCustomerId.Text);

  customer := TAdaptedCustomer.GetCustomer(customerID);
  try
    try
      lstCustomers.Items.Add(customer.ToString);
    except on E: Exception do
      ShowMessage(E.Message);
    end;
  finally
    customer.Free;
  end;

  edtCustomerId.Clear;
end;

{ AbstractFactory }

procedure TfrmDemo.btnCreateCarClick(Sender: TObject);
var
  carFactory: TAbstractCarFactory;
  car: TAbstractCar;

begin
  if cbbFactorySelect.ItemIndex < 0 then
    Exit;

  try
    with cbbFactorySelect do
    begin
      case ItemIndex of
        0: carFactory := TRenaultFactory.Create;
        1: carFactory := TVolvoFactory.Create;
        2: carFactory := TMercedesFactory.Create;
      end;
    end;

    car := carFactory.GetCar;
    lstCarsCreated.Items.Add(car.GetName);
  finally
    car.Free;
    carFactory.Free;
  end;
end;

procedure TfrmDemo.btnHandleRequestsClick(Sender: TObject);
var
  requests: TArray<SmallInt>;
  request: SmallInt;

begin
  requests := TArray<SmallInt>.Create(2, 5, 14, 22, 18, 3, 27, 20);

  FConcreteHandler1.Successor := FConcreteHandler2;
  FConcreteHandler2.Successor := FConcreteHandler3;

  for request in requests do
    lstHandlerOutput.Items.Add(FConcreteHandler1.HandleRequest(request));
end;

{ Bridge }

procedure TfrmDemo.swBathroomOff(Sender: TObject);
begin
  FSwitchAbstraction.Switch := FBathroomSwitch;
  lstSwitchInfo.Items.Add(FSwitchAbstraction.TurnOff);
end;

procedure TfrmDemo.swBathroomOn(Sender: TObject);
begin
  FSwitchAbstraction.Switch := FBathroomSwitch;
  lstSwitchInfo.Items.Add(FSwitchAbstraction.TurnOn);
end;

procedure TfrmDemo.swKitchenOff(Sender: TObject);
begin
  FSwitchAbstraction.Switch := FKitchenSwitch;
  lstSwitchInfo.Items.Add(FSwitchAbstraction.TurnOff);
end;

procedure TfrmDemo.swKitchenOn(Sender: TObject);
begin
  FSwitchAbstraction.Switch := FKitchenSwitch;
  lstSwitchInfo.Items.Add(FSwitchAbstraction.TurnOn);
end;

end.
